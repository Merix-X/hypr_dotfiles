-- Hyprland Lua configuration (Hyprland 0.55+)
-- Migrated from the supplied hyprland.conf.
-- Intel/Mesa-friendly: NVIDIA-specific environment variables and forced DRM
-- device ordering are intentionally omitted. Let Hyprland/Aquamarine select
-- the available Intel DRM device instead of assuming card0/card1 numbering.

----------------
-- MONITORS
----------------

hl.monitor({
    output = "eDP-1",
    mode = "1920x1080@60.03",
    position = "0x0",
    scale = 1,
})

hl.monitor({
    output = "HDMI-A-1",
    mode = "1920x1200@59.95",
    position = "-1920x0",
    scale = 1,
})

----------------
-- MY PROGRAMS
----------------

local terminal = "kitty"
local fileManager = "thunar"
local menu = "rofi -show drun"
local mainMod = "SUPER"

----------------
-- ENVIRONMENT
----------------

hl.env("GTK_THEME", "Adwaita:dark")
hl.env("XCURSOR_THEME", "Bibata-Modern-Amber")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Deliberately not set:
--   GBM_BACKEND=nvidia-drm
--   __GLX_VENDOR_LIBRARY_NAME=nvidia
--   LIBVA_DRIVER_NAME=nvidia
--   AQ_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
-- Mesa/VA-API driver selection is left to the installed Intel/Mesa stack;
-- forcing LIBVA_DRIVER_NAME=iHD could break older Intel hardware or systems
-- where the matching Intel media driver is not installed.

----------------
-- AUTOSTART
----------------

hl.on("hyprland.start", function()
    -- Start these programs directly on their intended workspaces.
    hl.dispatch(hl.dsp.exec_cmd("firefox", { workspace = "2 silent" }))
    hl.dispatch(hl.dsp.exec_cmd("spotify", { workspace = "3 silent" }))
    hl.dispatch(hl.dsp.exec_cmd(terminal, { workspace = "special:magic silent" }))

    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'")
    hl.exec_cmd('swaybg -i "$HOME/Pictures/Iusearchwallpaper.png" -m fill')
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("swayosd-libinput-backend")
    hl.exec_cmd("dunst")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("hyprctl setcursor Bibata-Modern-Amber 24")
end)

----------------
-- LOOK AND FEEL
----------------

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,
        col = {
            active_border = {
                colors = { "rgba(ff0055ff)", "rgba(66001aff)" },
                angle = 45,
            },
            inactive_border = "rgba(101012ff)",
        },
        layout = "dwindle",
    },
    decoration = {
        rounding = 6,
        active_opacity = 0.98,
        inactive_opacity = 0.90,
        shadow = {
            enabled = false,
        },
        blur = {
            enabled = true,
            -- Slightly reduced workload for Intel integrated graphics.
            size = 2,
            passes = 1,
        },
    },
    animations = {
        enabled = true,
    },
    dwindle = {
        preserve_split = true,
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },
})

----------------
-- ANIMATIONS
----------------

hl.curve("easeOutQuint", {
    type = "bezier",
    points = { { 0.23, 1 }, { 0.32, 1 } },
})
hl.curve("easeInOutCubic", {
    type = "bezier",
    points = { { 0.65, 0.05 }, { 0.36, 1 } },
})
hl.curve("linear", {
    type = "bezier",
    points = { { 0, 0 }, { 1, 1 } },
})
hl.curve("almostLinear", {
    type = "bezier",
    points = { { 0.5, 0.5 }, { 0.75, 1 } },
})
hl.curve("quick", {
    type = "bezier",
    points = { { 0.15, 0 }, { 0.1, 1 } },
})

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 4.1, bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", style = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 4, bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", style = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "quick" })

----------------
-- INPUT
----------------

hl.config({
    input = {
        kb_layout = "cz",
        kb_variant = "qwerty",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
    binds = {
        drag_threshold = 10,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

----------------
-- KEYBINDINGS
----------------

hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.exec_cmd("if command -v hyprshutdown >/dev/null 2>&1; then hyprshutdown; else hyprctl dispatch exit; fi"))
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprpicker -a"))
-- The original config assigned SUPER+P to both pseudo-tiling and hyprpicker.
-- Keep both functions without a key collision by moving pseudo-tiling to SUPER+SHIFT+P.
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + F", hl.dsp.window.float())

-- Focus windows with SUPER + arrow keys.
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + UP", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "d" }))

-- Switch workspaces with the number-row keycodes, independent of keyboard layout.
for i = 1, 10 do
    local keycode = i + 9
    hl.bind("SUPER + code:" .. keycode, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + code:" .. keycode, hl.dsp.window.move({ workspace = tostring(i), follow = false }))
end

hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

-- Cycle through existing workspaces using the mouse wheel.
hl.bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with SUPER + left/right mouse button.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Clipboard history.
hl.bind("SUPER + V", hl.dsp.exec_cmd("cliphist list | rofi -dmenu | cliphist decode | wl-copy"))

-- Volume and microphone controls.
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))

-- Brightness OSD controls.
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("swayosd-client --brightness raise"), { repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("swayosd-client --brightness lower"), { repeating = true })

-- Media controls; available even when an input inhibitor is active.
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Custom shortcuts.
hl.bind("SUPER + W", hl.dsp.exec_cmd("kitty --class floating_nmtui -e nmtui"))
hl.bind("Print", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SUPER + H", hl.dsp.exec_cmd("kitty --class hypr-config -e nano ~/.config/hypr/hyprland.lua"))
hl.bind("SUPER + O", hl.dsp.exec_cmd("kitty --class claude-code -e claude"))

----------------
-- WINDOW RULES
----------------

-- Ignore app requests to maximize windows.
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix some dragging issues with XWayland windows.
hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_initial_focus = true,
})

-- Hyprland-run window placement.
hl.window_rule({
    name = "move-hyprland-run",
    match = { class = "hyprland-run" },
    move = { 20, "monitor_h-120" },
    float = true,
})

-- Firefox transparency.
hl.window_rule({
    name = "firefox-transparency",
    match = { class = "^(firefox)$" },
    opacity = "0.95 0.85",
})

-- Floating Wi-Fi menu.
hl.window_rule({
    name = "wifi-menu",
    match = { class = "^(floating_nmtui)$" },
    float = true,
    size = { 600, 400 },
    center = true,
})

-- Floating calendar menu.
hl.window_rule({
    name = "calendar-menu",
    match = { class = "^(floating_cal)$" },
    float = true,
    size = { 700, 500 },
    center = true,
})
