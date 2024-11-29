# Terminal Configuration Setup

This setup includes configuration for both Alacritty (in Quake mode) and WezTerm terminals with AutoHotkey integration.

## Files

- `alacritty.toml`: Alacritty configuration file
- `wezterm.lua`: WezTerm configuration file
- `autohotkey-script.ahk`: AutoHotkey script for terminal management
- `setup-config.bat`: Setup script
- `terminal_settings.ini`: Settings for terminal behavior

## Features

- **Alacritty Quake Mode:**
  - Drops down from top of screen
  - Configurable height
  - Always-on-top
  - Optional auto-hide on focus loss
  - Toggle with Win + `

- **WezTerm Normal Mode:**
  - Standard window behavior
  - Optional auto-hide on focus loss
  - Toggle with Win + Enter

## Setup Instructions

1. **Prerequisites:**
   - Install [Alacritty](https://github.com/alacritty/alacritty/releases)
   - Install [WezTerm](https://wezfurlong.org/wezterm/installation.html)
   - Install [AutoHotkey](https://www.autohotkey.com/)

2. **Installation:**
   - Clone or download this repository
   - Run `setup-config.bat` as administrator
   - Follow the prompts to configure:
     - Alacritty Quake mode height
     - Auto-hide behavior for both terminals

## Configuration

### Settings (terminal_settings.ini)
- `AlacrittyQuakeHeight`: Height percentage for Quake mode (1-100)
- `AlacrittyHideOnLostFocus`: Auto-hide Alacritty when losing focus
- `WeztermHideOnLostFocus`: Auto-hide WezTerm when losing focus

## Keyboard Shortcuts

- `Win + ~`: Toggle Alacritty (Quake mode)
- `Win + Enter`: Toggle WezTerm

## Troubleshooting

- If terminals don't respond: Restart the AutoHotkey script
- If settings don't apply: Check terminal_settings.ini permissions
- For other issues: Rerun setup-config.bat as administrator
