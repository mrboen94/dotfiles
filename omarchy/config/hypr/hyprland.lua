-- Learn how to configure Hyprland: https://wiki.hypr.land/Configuring/Start/

-- Omarchy's bootstrap keeps path setup out of this user config.
dofile((os.getenv("OMARCHY_PATH") or "/usr/share/omarchy") .. "/default/hypr/bootstrap.lua")

-- Disable all Omarchy default bindings. Add your own in hypr/bindings.lua.
-- omarchy_default_bindings = false
--
-- Or disable only bindings for Omarchy's preinstalled apps/web apps while
-- keeping core window-manager bindings:
-- omarchy_preinstalled_bindings = false

-- Load Omarchy defaults.
require("default.hypr.omarchy")

-- Put your personal overrides in these files. They're loaded after Omarchy's
-- defaults so package updates can improve the defaults without rewriting your
-- ~/.config/hypr files.
require("hypr.monitors")
require("hypr.input")
require("hypr.bindings")
require("hypr.looknfeel")
require("hypr.autostart")

-- Toggle config flags dynamically.
require("default.hypr.toggles")

-- Add any other personal Hyprland configuration below.
-- o.window("qemu", { workspace = "5" })

-- Start each desktop session on workspace 1. This does not launch any apps or
-- bind the workspace to a monitor.
hl.on("hyprland.start", function()
  hl.dispatch(hl.dsp.focus({ workspace = "1" }))
end)

-- Place only the first window of each app when it opens. Subsequent windows
-- stay where the app puts them, and manually moved windows stay moved.
local function workspace_app(w)
  local class = w.class or ""

  if class == "chrome-ompifgpmddkgmclendfeacglnodjjndh-Default" then
    return "teams", "1"
  elseif class == "slack" or class == "Slack" then
    return "slack", "1"
  elseif class:match("^chrome%-app%.hey%.com") or class:match("^chromium%-app%.hey%.com") then
    return "hey", "1"
  elseif class == "org.telegram.desktop" or class == "TelegramDesktop" then
    return "telegram", "5"
  elseif class == "obsidian" or class == "md.obsidian.Obsidian" then
    return "obsidian", "4"
  end
end

hl.on("window.open", function(w)
  if not w then return end

  local app, workspace = workspace_app(w)
  if not app then return end

  for _, existing in ipairs(hl.get_windows()) do
    if existing.address ~= w.address and workspace_app(existing) == app then
      return
    end
  end

  hl.dispatch(hl.dsp.window.move({
    window = "address:" .. w.address,
    workspace = workspace,
    follow = true,
  }))
end)

-- Toolbox's XWayland tray widget can reopen outside the monitor bounds when
-- the external display is above the laptop display. Restore only if fully off-screen.
local function restore_toolbox_widget(w)
  if not w or w.class ~= "jetbrains-toolbox" then return end
  local address = w.address

  -- Toolbox positions the widget after activation, so check its final bounds.
  hl.timer(function()
    for _, current in ipairs(hl.get_windows()) do
      if current.address == address and current.monitor then
        local m = current.monitor
        local x, y = current.at.x, current.at.y
        local width, height = current.size.x, current.size.y
        if x + width <= m.x or x >= m.x + m.width or
           y + height <= m.y or y >= m.y + m.height then
          hl.dispatch(hl.dsp.window.center({ window = "address:" .. address }))
        end
        break
      end
    end
  end, { timeout = 200, type = "oneshot" })
end

hl.on("window.open", restore_toolbox_widget)
hl.on("window.active", restore_toolbox_widget)

-- When a monitor is unplugged, its split-monitor-workspaces block (e.g. 11-20)
-- ends up with no monitor that can reach it via SUPER+N. Move every window on
-- such an orphaned workspace to the same slot on the remaining monitors'
-- blocks (external slot 6 -> laptop slot 6). Blocks follow monitor id order,
-- like the plugin's default assignment.
local MONITOR_SLOTS = 10

local function rehome_orphaned_windows()
  local monitors = {}
  for _, m in ipairs(hl.get_monitors()) do
    if not m.is_mirror then table.insert(monitors, m) end
  end
  if #monitors == 0 then return end
  table.sort(monitors, function(a, b) return a.id < b.id end)
  local reachable = #monitors * MONITOR_SLOTS

  for _, w in ipairs(hl.get_windows()) do
    local ws = w.workspace and w.workspace.id
    if ws and ws > reachable then
      local slot = (ws - 1) % MONITOR_SLOTS + 1
      hl.dispatch(hl.dsp.window.move({
        window = "address:" .. w.address,
        workspace = tostring(slot),
        follow = false,
      }))
    end
  end
end

hl.on("monitor.removed", function()
  -- Let Hyprland finish migrating workspaces off the dead output first.
  hl.timer(rehome_orphaned_windows, { timeout = 500, type = "oneshot" })
end)
