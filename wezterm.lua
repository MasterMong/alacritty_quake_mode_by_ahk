local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window appearance
config.window_decorations = "NONE"
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Color scheme and opacity
config.color_scheme = 'Dracula'
config.window_background_opacity = 0.95

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = 11

-- Initial window size and position
config.initial_cols = 120
config.initial_rows = 30

-- Disable default key bindings that might interfere with the quake mode
config.disable_default_key_bindings = true
config.keys = {
    -- Add your custom key bindings here if needed
}

return config