local wezterm = require('wezterm')
local wezterm_config_nvim = wezterm.plugin.require('https://github.com/winter-again/wezterm-config.nvim')
local override_user_var = wezterm.plugin.require("https://github.com/mrboen94/wezterm-config.nvim")
	.override_user_var -- Allows neovim to control this config via override_user_var
local config = {}

--------------------------------------------------------------------------------
-- Appearance Helpers
--------------------------------------------------------------------------------
-- Setting fish as default shell
config.default_prog = { '/opt/homebrew/bin/fish', '-l' }

local function get_background_blur(_)
	return 10
end

local function get_background_opacity(_)
	return 0.99
end

--------------------------------------------------------------------------------
-- UI / UX Settings
--------------------------------------------------------------------------------

config.color_scheme = "Catppuccin Mocha"
config.use_fancy_tab_bar = false
config.window_decorations = "RESIZE|MACOS_FORCE_SQUARE_CORNERS|MACOS_FORCE_DISABLE_SHADOW"
config.window_frame = {
	border_left_width = "0",
	border_right_width = "0",
	border_bottom_height = "0",
	border_top_height = "0",
	border_left_color = "black",
	border_right_color = "black",
	border_bottom_color = "black",
	border_top_color = "black",
	font = require("wezterm").font("Comic Code Ligatures"),
}
config.colors = {
	tab_bar = {
		background = "#11111b",
		active_tab = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
			intensity = "Bold",
		},
		inactive_tab = {
			bg_color = "#181825",
			fg_color = "#7f849c",
		},
		inactive_tab_hover = {
			bg_color = "#1e1e2e",
			fg_color = "#cdd6f4",
		},
		new_tab = {
			bg_color = "#11111b",
			fg_color = "#89b4fa",
		},
		new_tab_hover = {
			bg_color = "#1e1e2e",
			fg_color = "#cdd6f4",
		},
	},
}
config.font = wezterm.font_with_fallback({
	"PragmataPro Mono Liga",
	"JetBrains Mono",
	"Menlo",
	"Symbols Nerd Font Mono",
})
config.font_size = 15
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = get_background_opacity()
config.macos_window_background_blur = get_background_blur()
config.inactive_pane_hsb = {
	saturation = 0.85,
	brightness = 0.72,
}

--------------------------------------------------------------------------------
-- Features and settings
--------------------------------------------------------------------------------

config.scrollback_lines = 3500

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------

local act = wezterm.action

config.keys = config.keys or {}

local function bind(key, mods, action)
	table.insert(config.keys, {
		key = key,
		mods = mods,
		action = action,
	})
end

local function wezterm_executable()
	local executable = os.getenv('WEZTERM_EXECUTABLE')
	if executable and executable ~= '' then
		return executable
	end

	if wezterm.target_triple:find('darwin') then
		return '/opt/homebrew/bin/wezterm'
	end

	return 'wezterm'
end

local function wezterm_cli(args)
	local argv = { wezterm_executable(), 'cli' }
	for _, arg in ipairs(args) do
		table.insert(argv, arg)
	end

	local ok, stdout, stderr = wezterm.run_child_process(argv)
	if not ok then
		wezterm.log_error('[wezterm.lua] wezterm cli failed: ' .. table.concat(argv, ' ') .. '\n' .. (stderr or ''))
	end
	return ok, stdout
end

local function move_pane(direction)
	local split_flag = {
		Left = '--left',
		Down = '--bottom',
		Up = '--top',
		Right = '--right',
	}

	return wezterm.action_callback(function(_, pane)
		local tab = pane:tab()
		if not tab then
			return
		end

		local target = tab:get_pane_direction(direction)
		if not target then
			return
		end

		local pane_id = tostring(pane:pane_id())
		local target_id = tostring(target:pane_id())
		if wezterm_cli({ 'split-pane', '--pane-id', target_id, split_flag[direction], '--move-pane-id', pane_id }) then
			wezterm_cli({ 'activate-pane', '--pane-id', pane_id })
		end
	end)
end

local function close_other_panes()
	return wezterm.action_callback(function(_, pane)
		local tab = pane:tab()
		if not tab then
			return
		end

		local active_pane_id = pane:pane_id()
		for _, other_pane in ipairs(tab:panes()) do
			if other_pane:pane_id() ~= active_pane_id then
				wezterm_cli({ 'kill-pane', '--pane-id', tostring(other_pane:pane_id()) })
			end
		end
		wezterm_cli({ 'activate-pane', '--pane-id', tostring(active_pane_id) })
	end)
end

local function move_pane_to_new_tab()
	return wezterm.action_callback(function(_, pane)
		local tab = pane:move_to_new_tab()
		if tab then
			tab:activate()
		end
	end)
end

-- Keep this explicit even though it is currently WezTerm's default CMD+w behavior:
-- close the current pane, and if it is the last pane, close the tab/window.
bind('w', 'CMD', act.CloseCurrentPane { confirm = true })

-- Split panes with CMD + Vim directions. This intentionally overrides macOS CMD+h hide.
bind('h', 'CMD', act.SplitPane { direction = 'Left', size = { Percent = 50 } })
bind('j', 'CMD', act.SplitPane { direction = 'Down', size = { Percent = 50 } })
bind('k', 'CMD', act.SplitPane { direction = 'Up', size = { Percent = 50 } })
bind('l', 'CMD', act.SplitPane { direction = 'Right', size = { Percent = 50 } })

-- Move focus between panes.
bind('h', 'CMD|CTRL', act.ActivatePaneDirection 'Left')
bind('j', 'CMD|CTRL', act.ActivatePaneDirection 'Down')
bind('k', 'CMD|CTRL', act.ActivatePaneDirection 'Up')
bind('l', 'CMD|CTRL', act.ActivatePaneDirection 'Right')

-- Move the active pane by relocating it next to the adjacent pane in that direction.
bind('h', 'CMD|SHIFT', move_pane('Left'))
bind('j', 'CMD|SHIFT', move_pane('Down'))
bind('k', 'CMD|SHIFT', move_pane('Up'))
bind('l', 'CMD|SHIFT', move_pane('Right'))

-- Pane and tab organization.
bind('o', 'CMD', close_other_panes())
bind('o', 'CMD|SHIFT', move_pane_to_new_tab())
bind('h', 'CMD|CTRL|SHIFT', act.MoveTabRelative(-1))
bind('l', 'CMD|CTRL|SHIFT', act.MoveTabRelative(1))

bind('X', 'CTRL|SHIFT', act.EmitEvent("clear-overrides"))

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

wezterm.on("clear-overrides", function(window, _)
	window:set_config_overrides({})
	wezterm.log_info("[wezterm.lua] Config overrides cleared.")
end)

wezterm.on('user-var-changed', function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	overrides = override_user_var(overrides, name, value)
	window:set_config_overrides(overrides)
end)

return config
