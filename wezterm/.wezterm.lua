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

-- and finally, return the configuration to wezterm
return config