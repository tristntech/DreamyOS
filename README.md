# DreamyOS

A beginner-friendly Linux system built on Arch Linux, with a clean, modern
Hyprland (Wayland) desktop in white and light blue.

> **Status: early development (stage 1 of 4).**
> The ISO boots into a live desktop you can try out. It can't be installed to a disk yet.

## Roadmap

- [ ] **Stage 1:** Bootable 64-bit live ISO that starts a Hyprland desktop *(being tested)*
- [ ] **Stage 2:** DreamyOS logo, polished theme, light/dark switch
- [ ] **Stage 3:** Graphical installer (Calamares) with Btrfs and automatic snapshots (Snapper)
- [ ] **Stage 4:** Welcome app, graphical app store, AUR helper (yay), simple `dreamy-*` commands

## Download the ISO

The ISO is built automatically by GitHub every time the code changes.

1. Open the **[Actions](../../actions)** tab of this repository (you must be signed in to GitHub).
2. Click the newest **Build DreamyOS ISO** run that has a green check mark.
3. Scroll down to **Artifacts** and download **dreamyos-iso**.
4. Unzip the download. Inside is `dreamyos-<date>-x86_64.iso`.

## Try it in VirtualBox

1. Click **New** and fill in:
   - **Name:** DreamyOS
   - **ISO Image:** the `.iso` file you downloaded
   - **Type:** Linux, **Subtype:** Arch Linux, **Version:** Arch Linux (64-bit)
   - Tick **Skip Unattended Installation**
2. **Hardware:** at least 4096 MB memory and 2 processors. Tick **Enable EFI**.
3. **Hard disk:** 30 GB (not used yet, but it'll be needed for installing later).
4. Click **Finish**. **Before starting**, open **Settings → Display → Screen** and set:
   - **Video Memory:** 128 MB (the maximum)
   - **Graphics Controller:** VMSVGA
   - **Enable 3D Acceleration:** ticked
5. Start the VM and pick the first entry in the boot menu. The desktop opens by itself.

Click inside the VM window so the **Super** (Windows) key goes to DreamyOS rather than
to Windows. Press the **Host key** (usually *Right Ctrl*) to give the mouse and keyboard
back to Windows.

### The live session

| | |
|---|---|
| User name | `dreamy` |
| Password | none |
| Admin (`sudo`) | works without a password |

## Keyboard shortcuts

Press **Super + /** at any time to see this list on screen.

| Shortcut | What it does |
|---|---|
| Super + Enter | Open terminal (Kitty) |
| Ctrl + Alt + T | Open terminal (alternative) |
| Super + Space | Open app launcher |
| Super + B | Open web browser (Firefox) |
| Super + E | Open file manager (Files) |
| Super + Q | Close window |
| Super + F | Fullscreen |
| Super + T | Float / unfloat window |
| Super + Arrow keys | Move focus between windows |
| Super + Shift + Arrow keys | Move window |
| Super + 1 to 9 | Switch workspace |
| Super + Shift + 1 to 9 | Send window to a workspace |
| Super + drag with mouse | Left button moves a window, right button resizes it |
| Print Screen | Screenshot an area (copied to the clipboard) |
| Super + Escape | Power menu (log out / restart / shut down) |
| Super + / | Show all shortcuts |

The **cloud button** at the top left of the bar also opens the app launcher, and the
**power button** at the top right opens the power menu, so you can do everything with the mouse too.

## Troubleshooting

- **The VM freezes or crashes, the screen goes black, or the desktop never shows up:**
  power off the VM, go to *Settings → Display* and **untick Enable 3D Acceleration**,
  then start it again. VirtualBox's 3D support is often unstable with modern Wayland
  desktops. Without it, DreamyOS automatically switches to *software rendering*: a bit
  slower, but much more reliable.
- **You end up at a text screen:** DreamyOS explains what happened. Type
  `dreamy-session` and press Enter to try again. The error log is in
  `~/.cache/dreamyos/hyprland.log`.
- **The Super key opens the Windows Start menu:** click inside the VM window first.

## How it's built (for the curious)

DreamyOS uses **archiso**, Arch Linux's official tool for making ISOs. We start
from Arch's own `releng` profile (the one used for the official Arch ISO) and
put our changes on top:

| Path | What it is |
|---|---|
| `iso/packages.x86_64` | Extra packages DreamyOS adds |
| `iso/airootfs/` | Files copied into the system (configs, scripts, wallpaper) |
| `iso/profiledef-extra.sh` | ISO name and file permissions |
| `scripts/build-iso.sh` | Combines everything and builds the ISO |
| `.github/workflows/build-iso.yml` | Tells GitHub to run the build in an Arch Linux container |

To build on a real Arch Linux machine instead: `sudo ./scripts/build-iso.sh`
(set `WORK_DIR` and `OUT_DIR` to choose where files go).

---

DreamyOS is an independent hobby project and is not affiliated with or endorsed by Arch Linux.
