#!/usr/bin/env bash
# Builds the DreamyOS live ISO.
#
# GitHub Actions runs this inside an Arch Linux container (see .github/workflows/build-iso.yml).
# You can also run it on a real Arch Linux machine:  sudo ./scripts/build-iso.sh
#
# How it works: we copy Arch's official "releng" archiso profile (the one used to
# build the official Arch ISO), put the DreamyOS files from iso/ on top, then build.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK_DIR="${WORK_DIR:-$REPO_DIR/work}"
OUT_DIR="${OUT_DIR:-$REPO_DIR/out}"
PROFILE_DIR="$WORK_DIR/profile"

if [[ $EUID -ne 0 ]]; then
    echo "Please run this as root, for example: sudo $0" >&2
    exit 1
fi

echo "==> Installing build tools"
pacman-key --init >/dev/null 2>&1 || true
pacman -Syu --noconfirm --needed archiso librsvg

echo "==> Preparing the archiso profile"
rm -rf "$PROFILE_DIR" "$WORK_DIR/build"
mkdir -p "$WORK_DIR" "$OUT_DIR"
cp -r /usr/share/archiso/configs/releng "$PROFILE_DIR"

# 1. DreamyOS files go on top of the releng files.
cp -rT "$REPO_DIR/iso/airootfs" "$PROFILE_DIR/airootfs"

# 2. Package list = releng packages + DreamyOS packages (comments and duplicates removed).
cat "$PROFILE_DIR/packages.x86_64" "$REPO_DIR/iso/packages.x86_64" \
    | sed -e 's/#.*//' -e 's/[[:space:]]*$//' -e '/^$/d' \
    | sort -u > "$PROFILE_DIR/packages.merged"
mv "$PROFILE_DIR/packages.merged" "$PROFILE_DIR/packages.x86_64"

# 3. ISO name and file permissions. Later lines in profiledef.sh override earlier ones.
cat "$REPO_DIR/iso/profiledef-extra.sh" >> "$PROFILE_DIR/profiledef.sh"

# 4. Boot menu names.
{ grep -rlZ 'Arch Linux' "$PROFILE_DIR/syslinux" "$PROFILE_DIR/efiboot" "$PROFILE_DIR/grub" 2>/dev/null || true; } \
    | xargs -0 -r sed -i -e 's/Arch Linux install medium/DreamyOS Live/g' -e 's/Arch Linux/DreamyOS/g'

# 5. Turn the SVG wallpapers into PNG images.
for svg in "$PROFILE_DIR"/airootfs/usr/share/backgrounds/dreamyos/*.svg; do
    [[ -e "$svg" ]] || continue
    rsvg-convert -w 3840 -h 2160 "$svg" -o "${svg%.svg}.png"
done

# 6. Check the Hyprland config before spending time on the ISO.
echo "==> Checking the Hyprland config"
HYPR_CONF="$REPO_DIR/iso/airootfs/etc/skel/.config/hypr/hyprland.lua"
pacman -S --noconfirm --needed lua hyprland >/dev/null
luac -p "$HYPR_CONF"   # Lua syntax errors stop the build here
id hyprcheck >/dev/null 2>&1 || useradd -m hyprcheck
install -d -o hyprcheck -m 700 /tmp/hyprcheck-runtime
install -o hyprcheck -m 644 "$HYPR_CONF" /home/hyprcheck/hyprland.lua
if verify_out="$(su hyprcheck -s /bin/bash -c \
        'XDG_RUNTIME_DIR=/tmp/hyprcheck-runtime Hyprland --verify-config -c /home/hyprcheck/hyprland.lua' 2>&1)"; then
    echo "::notice title=Hyprland config::Hyprland $(Hyprland --version | head -n 1) says the config is OK"
else
    # Shown as a warning on the GitHub run page. Doesn't stop the build, because
    # the check can also fail for reasons that have nothing to do with the config.
    echo "$verify_out" | tail -n 40
    echo "::warning title=Hyprland config check::$(echo "$verify_out" | grep -iE 'error|invalid|unknown|expected' | tail -n 15 | tr '\n' '|' | cut -c1-3000)"
fi

echo "==> Building the ISO (this takes a while)"
mkarchiso -v -w "$WORK_DIR/build" -o "$OUT_DIR" "$PROFILE_DIR"

echo "==> Done! The ISO is in $OUT_DIR"
ls -lh "$OUT_DIR"
