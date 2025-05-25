local wezterm = require("wezterm") -- Wezterm API import
local override_user_var = wezterm.plugin.require("https://github.com/mrboen94/wezterm-config.nvim").override_user_var -- Allows neovim to control this config via override_user_var
local config = {}

--------------------------------------------------------------------------------
-- Appearance Helpers
--------------------------------------------------------------------------------

local function scheme_for_appearance(appearance)
	return appearance:find("Dark") and "aethirlight" or "aethirlight"
end

local function get_background_blur(_)
	return 10
end

local function get_background_opacity(_)
	return 0.99
end

--------------------------------------------------------------------------------
-- UI / UX Settings
--------------------------------------------------------------------------------

config.color_scheme = "aethirlight"
config.use_fancy_tab_bar = true
config.window_decorations = "RESIZE"
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
-- config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.font = wezterm.font("PragmataPro Mono Liga")
config.font_size = 15
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = get_background_opacity(wezterm.gui.get_appearance())
config.macos_window_background_blur = get_background_blur(wezterm.gui.get_appearance())

--------------------------------------------------------------------------------
-- Keybindings
--------------------------------------------------------------------------------

config.keys = config.keys or {}
table.insert(config.keys, {
	key = "X",
	mods = "CTRL|SHIFT",
	action = wezterm.action.EmitEvent("clear-overrides"),
})

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

wezterm.on("clear-overrides", function(window, _)
	window:set_config_overrides({})
	wezterm.log_info("[wezterm.lua] Config overrides cleared.")
end)

wezterm.on("user-var-changed", function(window, pane, name, value)
	local overrides = window:get_config_overrides() or {}
	overrides = override_user_var(overrides, name, value)
	window:set_config_overrides(overrides)
end)

return config
