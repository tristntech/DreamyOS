-- ============================================================
--  DreamyOS – Hyprland configuration (Lua, Hyprland 0.57+)
--  Press SUPER + / to see all keyboard shortcuts.
--  Docs: https://wiki.hypr.land/configuring/
-- ============================================================

-- dreamy-session sets these before starting Hyprland.
local in_vm    = os.getenv("DREAMY_VM") == "1"
local software = os.getenv("DREAMY_SOFTWARE_RENDERING") == "1"
local light_effects = in_vm or software

-- --- Screen ---
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- --- Default apps ---
local terminal    = "kitty"
local browser     = "firefox"
local fileManager = "nautilus"
local menu        = "fuzzel"

-- --- Programs that start with the desktop ---
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("swaybg -i /usr/share/backgrounds/dreamyos/dreamy-light.png -m fill")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("sleep 2 && notify-send -t 15000 'Welcome to DreamyOS' 'SUPER + Enter: terminal   ·   SUPER + Space: apps   ·   SUPER + /: all shortcuts'")
end)

-- --- Environment ---
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")

-- --- Look and feel: white to light blue ---
hl.config({
    general = {
        gaps_in     = 6,
        gaps_out    = 14,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(7cc4ffee)", "rgba(c4e6ffee)" }, angle = 45 },
            inactive_border = "rgba(dbe9f6aa)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },

    decoration = {
        rounding       = 14,
        rounding_power = 2,
        active_opacity   = 1.0,
        inactive_opacity = light_effects and 1.0 or 0.97,

        shadow = {
            enabled      = not light_effects,
            range        = 18,
            render_power = 3,
            color        = "rgba(4a86c033)",
        },

        blur = {
            enabled = not light_effects,
            size    = 6,
            passes  = 2,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },

    ecosystem = {
        no_update_news   = true,
        no_donation_nag  = true,
    },

    cursor = {
        -- 1 = always use software cursors (needed in most virtual machines), 2 = automatic
        no_hardware_cursors = in_vm and 1 or 2,
    },

    debug = {
        -- also write logs to the terminal, so dreamy-session can save them
        enable_stdout_logs = true,
    },
})

-- --- Animations: soft and quick ---
hl.curve("dreamy", { type = "bezier", points = { { 0.22, 1 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })

hl.animation({ leaf = "global",     enabled = true, speed = 8,   bezier = "dreamy" })
hl.animation({ leaf = "border",     enabled = true, speed = 6,   bezier = "dreamy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4,   bezier = "dreamy", style = "popin 85%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,   bezier = "linear", style = "popin 85%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4,   bezier = "dreamy" })
hl.animation({ leaf = "layers",     enabled = true, speed = 4,   bezier = "dreamy", style = "fade" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,   bezier = "dreamy", style = "slide" })

-- --- Keyboard and mouse ---
hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = true,
        },
    },
})

-- --- Keyboard shortcuts ---
local mod = "SUPER"

hl.bind(mod .. " + Return",     hl.dsp.exec_cmd(terminal))
hl.bind("CTRL + ALT + T",       hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + Space",      hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + B",          hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + E",          hl.dsp.exec_cmd(fileManager))
hl.bind(mod .. " + slash",      hl.dsp.exec_cmd("dreamy-keybinds"))
hl.bind(mod .. " + Escape",     hl.dsp.exec_cmd("dreamy-power"))
hl.bind(mod .. " + SHIFT + M",  hl.dsp.exec_cmd("dreamy-logout"))

hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo())

-- Move focus / move windows
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mod .. " + " .. dir,             hl.dsp.focus({ direction = dir }))
    hl.bind(mod .. " + SHIFT + " .. dir,     hl.dsp.window.move({ direction = dir }))
end

-- Workspaces 1-9
for i = 1, 9 do
    hl.bind(mod .. " + " .. i,           hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. i,   hl.dsp.window.move({ workspace = i }))
end
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Move / resize windows with SUPER + mouse
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshot an area to the clipboard
hl.bind("Print", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))

-- Volume keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })

-- --- Window rules ---
hl.window_rule({
    -- Ignore "maximize" requests from apps; Hyprland tiles windows instead.
    name  = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})
