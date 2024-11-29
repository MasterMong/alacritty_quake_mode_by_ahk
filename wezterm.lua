local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Window appearance settings
config.window_decorations = "INTEGRATED_BUTTONS"
config.initial_rows = 30
config.initial_cols = 120

-- Don't auto-hide the title bar
config.hide_tab_bar_if_only_one_tab = false
config.window_close_confirmation = 'NeverPrompt'

-- Color scheme and opacity
config.color_scheme = 'Dracula'
config.window_background_opacity = 0.95

-- Font configuration
config.font = wezterm.font('JetBrains Mono')
config.font_size = 11

-- Disable default key bindings that might interfere with the quake mode
config.disable_default_key_bindings = true
config.keys = {
    -- Add your custom key bindings here if needed
}

return config