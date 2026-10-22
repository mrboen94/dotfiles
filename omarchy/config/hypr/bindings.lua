-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Reposition the external monitor relative to the laptop screen.
o.bind("SUPER + CTRL + ALT + UP", "Move external monitor above", "hypr-monitor-position up")
o.bind("SUPER + CTRL + ALT + DOWN", "Move external monitor below", "hypr-monitor-position down")
o.bind("SUPER + CTRL + ALT + LEFT", "Move external monitor to the left", "hypr-monitor-position left")
o.bind("SUPER + CTRL + ALT + RIGHT", "Move external monitor to the right", "hypr-monitor-position right")

-- Swap Agent and ChatGPT: Agent on SUPER+SHIFT+A, ChatGPT on SUPER+SHIFT+CTRL+A.
hl.unbind("SUPER + SHIFT + A")
hl.unbind("SUPER + SHIFT + CTRL + A")
o.bind("SUPER + SHIFT + A", "Agent", "omarchy-agent --pick")
o.bind("SUPER + SHIFT + CTRL + A", "ChatGPT", { webapp = "https://chatgpt.com" })

-- 1Password Quick Access. 1Password's own global hotkey doesn't work under
-- Wayland (Electron's globalShortcut is X11-only), so this calls its
-- --quick-access CLI flag directly instead, which relays to the running
-- instance via Electron's single-instance IPC.
o.bind("CTRL + SHIFT + SPACE", "1Password Quick Access", "1password --quick-access")

-- Per-monitor workspaces via the split-monitor-workspaces plugin (hyprpm).
-- Every monitor gets its own slots 1-10 (plugin default count); Super+N acts on the focused monitor.
-- Plugin ids are laid out in blocks of SLOTS per monitor (1-10, 11-20, ...).
-- Looked up lazily: the plugin is loaded by "hyprpm reload" from autostart.lua,
-- after this file has run at login.
local function smw()
  return hl.plugin.split_monitor_workspaces
end
local SLOTS = 10

local function block_first(ws_id)
  return math.floor((ws_id - 1) / SLOTS) * SLOTS + 1
end

for slot = 1, SLOTS do
  local key = "code:" .. tostring(slot + 9)  -- keys 1..9, 0
  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)
  o.bind("SUPER + " .. key, "Switch to workspace " .. slot, function() smw().workspace(slot) end)
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. slot, function() smw().move_to_workspace(slot) end)
  o.bind("SUPER + SHIFT + ALT + " .. key, "Move window silently to workspace " .. slot, function() smw().move_to_workspace_silent(slot) end)
end

-- Cycle only through this monitor's workspaces.
hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + CTRL + TAB")
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")
o.bind("SUPER + TAB", "Next workspace on this monitor", function() smw().cycle_workspaces("next") end)
o.bind("SUPER + SHIFT + TAB", "Previous workspace on this monitor", function() smw().cycle_workspaces("prev") end)
o.bind("SUPER + CTRL + TAB", "Former workspace on this monitor", hl.dsp.focus({ workspace = "previous_per_monitor" }))
o.bind("SUPER + mouse_down", "Next workspace on this monitor", function() smw().cycle_workspaces("next") end)
o.bind("SUPER + mouse_up", "Previous workspace on this monitor", function() smw().cycle_workspaces("prev") end)

-- Caps Lock (already remapped to an extra Ctrl in input.lua via "ctrl:nocaps")
-- also doubles as a vim-style window-management key: hold it and press hjkl
-- to move focus, or add Alt to move just the focused window to the monitor
-- in that direction (the existing SUPER+SHIFT+ALT+arrows keymaps still move
-- the whole workspace, untouched). This is bound by the physical key's raw
-- code (66 = Caps Lock) instead of its Ctrl keysym, so it only fires while
-- Caps Lock itself is physically held and never collides with a Ctrl+h/j/k/l
-- chord typed from the real Ctrl key.
local capslock_wm_binds = {}

-- Never leave the window's monitor by accident. Hyprland's directional swap
-- normally spills onto the neighbouring monitor when there is no window in
-- that direction; turn that off so hjkl stays on the current monitor.
hl.config({ binds = { window_direction_monitor_fallback = false } })

-- First/last workspace id of the block a workspace id belongs to.
local function local_block(ws_id)
  local first = block_first(ws_id)
  return first, first + SLOTS - 1
end

-- Returns the monitor that sits in that direction, or nil (edge-adjacent on the layout
-- and overlapping on the other axis). Checked up front because dispatching a
-- monitor move with nothing there raises an "Invalid monitor" error.
local function monitor_toward(monitor, direction)
  if not monitor then
    return nil
  end
  local x, y = monitor.x, monitor.y
  local w, h = monitor.width / monitor.scale, monitor.height / monitor.scale
  for _, other in ipairs(hl.get_monitors()) do
    if other.id ~= monitor.id and not other.is_mirror then
      local ox, oy = other.x, other.y
      local ow, oh = other.width / other.scale, other.height / other.scale
      local v_overlap = oy < y + h and oy + oh > y
      local h_overlap = ox < x + w and ox + ow > x
      if (direction == "l" and ox + ow <= x and v_overlap)
        or (direction == "r" and ox >= x + w and v_overlap)
        or (direction == "u" and oy + oh <= y and h_overlap)
        or (direction == "d" and oy >= y + h and h_overlap) then
        return other
      end
    end
  end
  return nil
end

-- True when another tiled window on the same workspace sits in that direction.
-- Hyprland's own directional focus/swap will happily pick a window that is not
-- actually that way (e.g. "up" between two side-by-side windows), which would
-- keep us from ever reaching the monitor hop, so check the geometry ourselves.
local function neighbour_toward(window, direction)
  if not window or not window.at or not window.size or not window.workspace then
    return false
  end
  local tol = 24 -- covers gaps and borders between tiles
  local x, y = window.at.x, window.at.y
  local w, h = window.size.x, window.size.y
  for _, other in ipairs(hl.get_windows()) do
    if other.address ~= window.address and other.mapped and not other.hidden and not other.floating
      and other.workspace and other.workspace.id == window.workspace.id and other.at and other.size then
      local ox, oy = other.at.x, other.at.y
      local ow, oh = other.size.x, other.size.y
      local v_overlap = oy < y + h and oy + oh > y
      local h_overlap = ox < x + w and ox + ow > x
      if (direction == "l" and ox + ow <= x + tol and v_overlap)
        or (direction == "r" and ox >= x + w - tol and v_overlap)
        or (direction == "u" and oy + oh <= y + tol and h_overlap)
        or (direction == "d" and oy >= y + h - tol and h_overlap) then
        return true
      end
    end
  end
  return false
end

-- Caps + Alt + hjkl, three tiers:
--   1. swap with the neighbouring window in that direction, if any;
--   2. otherwise, if there is a monitor that way, move the window onto it
--      WITHOUT swapping with anything there: onto the same-numbered slot if
--      that monitor shows an empty workspace, else onto what it shows;
--   3. otherwise left/right go to the previous/next workspace on this monitor
--      (no wrap; stops at slot 1 / slot 10).
-- Needs binds.window_direction_monitor_fallback = false (set above) so tier 1
-- never spills onto another monitor by itself.
local function move_window_directionally(direction)
  return function()
    local before = hl.get_active_window()
    if not before then
      return
    end

    local before_x = before.at and before.at.x
    local before_y = before.at and before.at.y
    local before_ws = before.workspace and before.workspace.id
    local before_mon = before.monitor and before.monitor.id

    local function changed()
      local after = hl.get_window("address:" .. before.address)
      if not after then
        return true
      end
      return (after.at and (after.at.x ~= before_x or after.at.y ~= before_y))
        or (after.workspace and after.workspace.id) ~= before_ws
        or (after.monitor and after.monitor.id) ~= before_mon
    end

    if neighbour_toward(before, direction) then
      hl.dispatch(hl.dsp.window.swap({ direction = direction }))
      if changed() then
        return
      end
    end

    local target_monitor = monitor_toward(before.monitor, direction)
    if target_monitor then
      -- Slot numbers line up across monitors (each monitor has its own block of ids, so slot N is
      -- the same on both). If the other monitor is showing an empty
      -- workspace, show the SAME slot there and put the window on it; if it
      -- is showing something with windows, land on that and leave it be.
      local shown = target_monitor.active_workspace
      if shown and shown.is_empty and before_ws then
        local slot_id = block_first(shown.id) + (before_ws - block_first(before_ws))
        hl.dispatch(hl.dsp.window.move({ workspace = tostring(slot_id), follow = true }))
      else
        hl.dispatch(hl.dsp.window.move({ monitor = direction, follow = true }))
      end
      return
    end
    if direction ~= "l" and direction ~= "r" then
      return
    end

    -- Step to the neighbouring workspace on this monitor, creating it if it
    -- does not exist yet. No wrap-around: the far end of ten slots is not
    -- "next to" the first, and a window sent there is hard to find again.
    local first, last = local_block(before_ws or 1)
    local current = before_ws or first
    local target = direction == "r" and current + 1 or current - 1
    if target < first or target > last then
      return
    end
    hl.dispatch(hl.dsp.window.move({ workspace = tostring(target), follow = true }))
  end
end

-- Caps + hjkl focus: move to the neighbouring window; at the edge, hop to the
-- monitor in that direction. Done by hand because the monitor fallback that
-- Hyprland applies to focus is the same switch we turned off for swapping.
local function focus_directionally(direction)
  return function()
    local before = hl.get_active_window()
    if before and neighbour_toward(before, direction) then
      hl.dispatch(hl.dsp.focus({ direction = direction }))
      return
    end
    if monitor_toward(hl.get_active_monitor(), direction) then
      hl.dispatch(hl.dsp.focus({ monitor = direction }))
    end
  end
end

local function capslock_wm_enable()
  if #capslock_wm_binds > 0 then
    return
  end

  local directions = {
    { key = "h", dir = "l" },
    { key = "j", dir = "d" },
    { key = "k", dir = "u" },
    { key = "l", dir = "r" },
  }

  for _, d in ipairs(directions) do
    table.insert(
      capslock_wm_binds,
      hl.bind("CTRL + " .. d.key, focus_directionally(d.dir), { description = "Focus " .. d.dir .. " window (or monitor)" })
    )
    table.insert(
      capslock_wm_binds,
      hl.bind(
        "CTRL + ALT + " .. d.key,
        move_window_directionally(d.dir),
        { description = "Move window " .. d.dir .. " (swap, else next monitor, else next workspace)" }
      )
    )
  end
end

local function capslock_wm_disable()
  for _, keybind in ipairs(capslock_wm_binds) do
    keybind:unbind()
  end
  capslock_wm_binds = {}
end

hl.bind("code:66", capslock_wm_enable, { non_consuming = true, description = "Enable Caps Lock window-management mode" })
hl.bind("code:66", capslock_wm_disable, { release = true, non_consuming = true, description = "Disable Caps Lock window-management mode" })
