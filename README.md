# Alacritty and AutoHotkey Setup

This setup includes configuration for Alacritty terminal and an AutoHotkey script to toggle the terminal visibility using a keyboard shortcut.

## Files

- `alacritty.toml`: Alacritty configuration file.
- `autohotkey-script.ahk`: AutoHotkey script to toggle Alacritty terminal visibility.
- `setup-config.bat`: Batch file to set up the configuration.

## Setup Instructions

1. **Download and Install Alacritty:**
   - Download Alacritty from [Alacritty GitHub Releases](https://github.com/alacritty/alacritty/releases).
   - Install Alacritty on your system.

2. **Download and Install AutoHotkey:**
   - Download AutoHotkey from [AutoHotkey Official Website](https://www.autohotkey.com/).
   - Install AutoHotkey on your system.

3. **Run the Setup Script:**
   - Place `alacritty.toml`, `autohotkey-script.ahk`, and `setup-config.bat` in the same directory.
   - Run `setup-config.bat` by double-clicking it.
   - The script will:
     - Copy `alacritty.toml` to `%APPDATA%\alacritty\alacritty.toml`.
     - Create a shortcut for `autohotkey-script.ahk` in the startup folder.

4. **Configure Terminal Height (Optional):**
   - Open `autohotkey-script.ahk` in a text editor.
   - Modify the `terminalHeightPercent` variable to set the terminal height as a percentage of the screen height. For example, to set the terminal height to 50% of the screen height, set `terminalHeightPercent := 50`.

## Usage

- **Toggle Terminal Visibility:**
  - Press `Win + Enter` to toggle the visibility of the Alacritty terminal.

- **Hide Terminal When Focus is Lost (Optional):**
  - The script includes an optional feature to hide the terminal when it loses focus. This feature is enabled by default.

## Notes

- Ensure that the paths in the script match the installation paths of Alacritty and AutoHotkey on your system.
- You can customize the script further as per your requirements.

## Troubleshooting

- If the setup script fails to create the Alacritty configuration directory, ensure that you have the necessary permissions to create directories in `%APPDATA%`.
- If the terminal does not toggle as expected, verify that the `terminalPath` and `terminalTitle` variables in `autohotkey-script.ahk` are set correctly.
