# Start the DreamyOS desktop automatically after logging in on the first screen (tty1).
# To turn this off, create the file ~/.config/dreamyos/no-autostart
if [ "$(id -u)" -ne 0 ] \
    && [ -z "${WAYLAND_DISPLAY:-}" ] \
    && [ "$(tty)" = "/dev/tty1" ] \
    && [ ! -e "$HOME/.config/dreamyos/no-autostart" ] \
    && command -v dreamy-session >/dev/null 2>&1; then
    dreamy-session
fi
