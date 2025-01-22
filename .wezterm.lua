-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
  config = wezterm.config_builder()
end

function scheme_for_appearance(appearance)
  if appearance:find "Dark" then
    return "nord"
  else
    return "Catppuccin Latte"
  end
end

function get_background_blur(appearance)
  if appearance:find "Dark" then
    return 10
  else
    return 10
  end
end

function get_background_opacity(appearance)
  if appearance:find "Dark" then
    return 0.99
  else
    return 0.99
  end
end

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = scheme_for_appearance(wezterm.gui.get_appearance())
config.font = wezterm.font("PragmataPro Liga")
config.font_size = 18
config.adjust_window_size_when_changing_font_size = false
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = get_background_opacity(wezterm.gui.get_appearance())
config.macos_window_background_blur = get_background_blur(wezterm.gui.get_appearance())

-- and finally, return the configuration to wezterm
return config
