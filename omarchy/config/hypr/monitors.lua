-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))

-- Laptop display: pinned at the origin so other monitors place relative to it.
hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = omarchy_monitor_scale })

-- Any other (external/dock) monitor: default to above the laptop screen.
-- Change the live position any time with SUPER + CTRL + ALT + <arrow> (see bindings.lua).
hl.monitor({ output = "", mode = "preferred", position = "auto-up", scale = omarchy_monitor_scale })

-- Workspaces are managed per monitor by the split-monitor-workspaces plugin
-- (see bindings.lua); no workspace rules here. Plugin defaults apply
-- (10 workspaces per monitor): its settings are not exposed to the Lua config.

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
