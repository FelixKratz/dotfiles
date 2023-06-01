local wezterm = require("wezterm")
local action = wezterm.action

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.window_decorations = "RESIZE"
config.color_scheme = 'Catppuccin Mocha'
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.font = wezterm.font('Liga SFMono Nerd Font', { weight = "Bold" })
config.harfbuzz_features = { 'calt=1', 'clig=1', 'liga=1' }
config.send_composed_key_when_left_alt_is_pressed = true
config.font_size = 14.0
config.cell_width = 0.9

config.leader = { key = 'Space', mods = 'SHIFT' }

config.keys = {
  {
    key = 'j',
    mods = 'CTRL',
    action = action.ActivatePaneDirection "Left"
  },
  {
    key = 'k',
    mods = 'CTRL',
    action = action.ActivatePaneDirection "Down"
  },
  {
    key = 'l',
    mods = 'CTRL',
    action = action.ActivatePaneDirection "Up"
  },
  {
    key = 'ö',
    mods = 'CTRL',
    action = action.ActivatePaneDirection "Right"
  },
  {
    key = 'UpArrow',
    mods = 'CTRL',
    action = action.AdjustPaneSize { "Up", 1 }
  },
  {
    key = 'DownArrow',
    mods = 'CTRL',
    action = action.AdjustPaneSize { "Down", 1 }
  },
  {
    key = 'LeftArrow',
    mods = 'CTRL',
    action = action.AdjustPaneSize { "Left", 1 }
  },
  {
    key = 'RightArrow',
    mods = 'CTRL',
    action = action.AdjustPaneSize { "Right", 1 }
  },
  {
    key = 's',
    mods = 'CTRL',
    action = action.SplitHorizontal { domain = "CurrentPaneDomain" }
  },
  {
    key = 'v',
    mods = 'CTRL',
    action = action.SplitVertical { domain = "CurrentPaneDomain" }
  },
  {
    key = 'f',
    mods = 'CTRL',
    action = action.TogglePaneZoomState
  }
}
return config
