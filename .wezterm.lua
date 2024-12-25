-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

config.color_scheme = 'Neutron (Gogh)'
config.font = wezterm.font("MesloLGS Nerd Font Mono")
config.font_size = 16

config.enable_tab_bar = false

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

config.window_padding = {
  left = '16px',
  right = '16px',
  top = '44px',
  bottom = '16px',
}

config.keys = {
  {
    key = 'r',
    mods = 'CMD|SHIFT',
    action = wezterm.action.ReloadConfiguration,
  },
}

-- config.colors = {
-- 	foreground = "#ecffff",
-- 	background = "#1a1a1a",
-- 	cursor_bg = "#93d479",
-- 	cursor_border = "#93d479",
-- 	cursor_fg = "#212121",
-- 	selection_bg = "#4a4a4a",
-- 	selection_fg = "#ecffff",
-- 	ansi = { "#214969", "#f07178", "#93d479", "#ffcb6b", "#78d9ff", "#a277ff", "#80cbc4", "#80cbc4" },
-- 	brights = { "#214969", "#f07178", "#93d479", "#ffcb6b", "#A277FF", "#a277ff", "#80cbc4", "#80cbc4" },
-- }

-- and finally, return the configuration to wezterm
return config