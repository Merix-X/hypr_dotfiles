-- Hyprland 0.55+
-- ~/.config/hypr/hyprland.lua
-- MacBook: NVIDIA GeForce 9400M, nouveau, Wayland

----------------
-- MONITORS
----------------

-- Internal MacBook display
hl.monitor({
    output = "LVDS-1",
    mode = "preferred",
    position = "0x0",
    scale = 0.8,
})

-- External display
hl.monitor({
    output = "HDMI-A-1",
    mode = "preferred",
    position = "auto",
    scale = 0.8,
})

-- Fallback for other displays
hl.monitor({
    output = "",
    mode = "preferred",
    position = "auto",
    scale = 0.8,
})

----------------
-- PROGRAMS
----------------

local terminal = "kitty"
local fileManager = "thunar"
local menu = "rofi -show drun"

----------------
-- ENVIRONMENT
----------------

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("_JAVA_AWT_WM_NONREPARENTING", "1")

-- Use the kernel's existing graphics driver (nouveau).
-- Do not force proprietary NVIDIA-specific variables here.

----------------
-- CURSOR
----------------

hl.config({
    cursor = {
        invisible = false,
        no_hardware_cursors = 1,
        sync_gsettings_theme = true,
    },
})

----------------
-- AUTOSTART
----------------

hl.on("hyprland.start", function()
    hl.exec_cmd(
        "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
    )
    hl.exec_cmd(
        "gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'"
    )
    hl.exec_cmd(
        "gsettings set org.gnome.desktop.interface cursor-theme 'Adwaita'"
    )
    hl.exec_cmd(
        "gsettings set org.gnome.desktop.interface cursor-size 24"
    )

    hl.exec_cmd(
        'swaybg -i "$HOME/Pictures/wallpapers/wallpaper.jpg" -m fill'
    )
    hl.exec_cmd("waybar")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("swayosd-libinput-backend")
    hl.exec_cmd("dunst")
    hl.exec_cmd("udiskie")
    hl.exec_cmd("hyprctl setcursor Adwaita 24")
end)

----------------
-- APPEARANCE
----------------

hl.config({
    general = {
        gaps_in = 4,
        gaps_out = 8,
        border_size = 2,

        col = {
            active_border = {
                colors = {
                    "rgba(ff0055ff)",
                    "rgba(66001aff)",
                },
                angle = 45,
            },

            inactive_border = "rgba(101012ff)",
        },

        layout = "dwindle",
    },

    decoration = {
        rounding = 6,
        active_opacity = 1.0,
        inactive_opacity = 0.95,

        -- Keep effects lightweight for the older NVIDIA GPU.
        shadow = {
            enabled = false,
        },

        blur = {
            enabled = false,
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

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
    },

    input = {
        kb_layout = "cz",
        kb_variant = "qwerty",
        follow_mouse = 1,
        sensitivity = 0,

        touchpad = {
            natural_scroll = false,
        },
    },
})

----------------
-- ANIMATIONS
----------------

hl.curve("easeOutQuint", {
    type = "bezier",
    points = {
        { 0.23, 1 },
        { 0.32, 1 },
    },
})

hl.curve("easeInOutCubic", {
    type = "bezier",
    points = {
        { 0.65, 0.05 },
        { 0.36, 1 },
    },
})

hl.curve("linear", {
    type = "bezier",
    points = {
        { 0, 0 },
        { 1, 1 },
    },
})

hl.curve("almostLinear", {
    type = "bezier",
    points = {
        { 0.5, 0.5 },
        { 0.75, 1 },
    },
})

hl.curve("quick", {
    type = "bezier",
    points = {
        { 0.15, 0 },
        { 0.1, 1 },
    },
})

hl.animation({
    leaf = "global",
    enabled = true,
    speed = 10,
    bezier = "default",
})

hl.animation({
    leaf = "border",
    enabled = true,
    speed = 5.39,
    bezier = "easeOutQuint",
})

hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    bezier = "easeOutQuint",
})

hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.1,
    bezier = "easeOutQuint",
    style = "popin 87%",
})

hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 1.49,
    bezier = "linear",
    style = "popin 87%",
})

hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 1.73,
    bezier = "almostLinear",
})

hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.46,
    bezier = "almostLinear",
})

hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3.03,
    bezier = "quick",
})

hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 3.81,
    bezier = "easeOutQuint",
})

hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "easeOutQuint",
    style = "fade",
})

hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 1.5,
    bezier = "linear",
    style = "fade",
})

hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 1.79,
    bezier = "almostLinear",
})

hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 1.39,
    bezier = "almostLinear",
})

hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 1.94,
    bezier = "almostLinear",
    style = "fade",
})

hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 1.21,
    bezier = "almostLinear",
    style = "fade",
})

hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 1.94,
    bezier = "almostLinear",
    style = "fade",
})

hl.animation({
    leaf = "zoomFactor",
    enabled = true,
    speed = 7,
    bezier = "quick",
})

----------------
-- KEYBINDINGS
----------------

-- Applications
hl.bind("SUPER + Q", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + C", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.exit())
hl.bind("SUPER + E", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + R", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P", hl.dsp.exec_cmd("hyprpicker -a"))
hl.bind("SUPER + SHIFT + P", hl.dsp.window.pseudo())
hl.bind("SUPER + J", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + F", hl.dsp.window.float())

-- Window focus
hl.bind("SUPER + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + UP", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + DOWN", hl.dsp.focus({ direction = "d" }))

-- Workspaces
for i = 1, 10 do
    local keycode = i + 9

    hl.bind(
        "SUPER + code:" .. keycode,
        hl.dsp.focus({ workspace = i })
    )

    hl.bind(
        "SUPER + SHIFT + code:" .. keycode,
        hl.dsp.window.move({
            workspace = tostring(i),
            follow = false,
        })
    )
end

hl.bind("SUPER + S", hl.dsp.workspace.toggle_special("magic"))

hl.bind(
    "SUPER + SHIFT + S",
    hl.dsp.window.move({ workspace = "special:magic" })
)

-- Workspace scrolling
hl.bind("mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move and resize windows
hl.bind(
    "SUPER + mouse:272",
    hl.dsp.window.drag(),
    { mouse = true }
)

hl.bind(
    "SUPER + mouse:273",
    hl.dsp.window.resize(),
    { mouse = true }
)

-- Clipboard history
hl.bind(
    "SUPER + V",
    hl.dsp.exec_cmd(
        "cliphist list | rofi -dmenu | cliphist decode | wl-copy"
    )
)

----------------
-- DISPLAY BRIGHTNESS
----------------

hl.bind(
    "XF86MonBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -d nvidia_backlight set 5%-"),
    { repeating = true }
)

hl.bind(
    "XF86MonBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -d nvidia_backlight set 5%+"),
    { repeating = true }
)

-- F1/F2 fallback when Fn sends ordinary function keys
hl.bind(
    "F1",
    hl.dsp.exec_cmd("brightnessctl -d nvidia_backlight set 5%-"),
    { repeating = true }
)

hl.bind(
    "F2",
    hl.dsp.exec_cmd("brightnessctl -d nvidia_backlight set 5%+"),
    { repeating = true }
)

----------------
-- KEYBOARD BACKLIGHT
----------------

-- The MacBook exposes this device as smc::kbd_backlight.
-- The XF86 keysyms match the keyboard events observed with evtest.

hl.bind(
    "XF86KbdBrightnessDown",
    hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%-"),
    { repeating = true }
)

hl.bind(
    "XF86KbdBrightnessUp",
    hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%+"),
    { repeating = true }
)

-- F5/F6 fallback when Fn mode sends ordinary function keys
hl.bind(
    "F5",
    hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%-"),
    { repeating = true }
)

hl.bind(
    "F6",
    hl.dsp.exec_cmd("brightnessctl -d '*::kbd_backlight' set 10%+"),
    { repeating = true }
)

----------------
-- AUDIO
----------------

hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ),
    { locked = true, repeating = true }
)

hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(
        "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ),
    { locked = true, repeating = true }
)

-- F11/F12 fallback when Fn mode sends ordinary function keys
hl.bind(
    "F11",
    hl.dsp.exec_cmd(
        "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
    ),
    { locked = true, repeating = true }
)

hl.bind(
    "F12",
    hl.dsp.exec_cmd(
        "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
    ),
    { locked = true, repeating = true }
)

----------------
-- MEDIA
----------------

hl.bind(
    "XF86AudioPrev",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)

hl.bind(
    "XF86AudioPlay",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioPause",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "XF86AudioNext",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)

-- F-key fallbacks
hl.bind(
    "F7",
    hl.dsp.exec_cmd("playerctl previous"),
    { locked = true }
)

hl.bind(
    "F8",
    hl.dsp.exec_cmd("playerctl play-pause"),
    { locked = true }
)

hl.bind(
    "F9",
    hl.dsp.exec_cmd("playerctl next"),
    { locked = true }
)

----------------
-- UTILITIES
----------------

hl.bind(
    "Print",
    hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy')
)

hl.bind(
    "SUPER + W",
    hl.dsp.exec_cmd("kitty --class floating_nmtui -e nmtui")
)

hl.bind(
    "SUPER + H",
    hl.dsp.exec_cmd(
        "kitty --class hypr-config -e nano ~/.config/hypr/hyprland.lua"
    )
)

----------------
-- WINDOW RULES
----------------

hl.window_rule({
    name = "suppress-maximize-events",
    match = {
        class = ".*",
    },
    suppress_event = "maximize",
})

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

hl.window_rule({
    name = "firefox-transparency",
    match = {
        class = "^(firefox)$",
    },
    opacity = "0.95 0.85",
})

hl.window_rule({
    name = "wifi-menu",
    match = {
        class = "^(floating_nmtui)$",
    },
    float = true,
    size = { 600, 400 },
    center = true,
})
