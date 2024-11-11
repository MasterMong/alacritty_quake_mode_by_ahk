@echo off

REM Set common paths
set AHK_SCRIPT_PATH=%~dp0autohotkey-script.ahk
set AHK_SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-script.lnk
set SETTINGS_PATH=%~dp0terminal_settings.ini

REM Terminal-specific paths
set ALACRITTY_CONFIG_PATH=%APPDATA%\alacritty\alacritty.toml
set WEZTERM_CONFIG_PATH=%USERPROFILE%\.config\wezterm\wezterm.lua

REM Ask user for preferred terminal
choice /C WA /N /M "Choose your terminal [W]ezTerm or [A]lacritty: "
if errorlevel 2 (
    set SELECTED_TERMINAL=alacritty
    echo Setting up Alacritty...
    
    REM Create alacritty config directory if it doesn't exist
    if not exist %APPDATA%\alacritty mkdir %APPDATA%\alacritty
    
    REM Copy alacritty config
    copy /Y "%~dp0alacritty.toml" "%ALACRITTY_CONFIG_PATH%"
) else (
    set SELECTED_TERMINAL=wezterm
    echo Setting up WezTerm...
    
    REM Create wezterm config directory if it doesn't exist
    if not exist %USERPROFILE%\.config\wezterm mkdir %USERPROFILE%\.config\wezterm
    
    REM Copy wezterm config
    copy /Y "%~dp0wezterm.lua" "%WEZTERM_CONFIG_PATH%"
)

REM Configure additional settings
choice /C YN /N /M "Hide terminal when focus is lost? (Y/N): "
if errorlevel 2 (
    set HIDE_ON_FOCUS_LOST=false
) else (
    set HIDE_ON_FOCUS_LOST=true
)

set /P TERMINAL_HEIGHT="Enter terminal height percentage (1-100) [default=100]: "
if "%TERMINAL_HEIGHT%"=="" set TERMINAL_HEIGHT=100

REM Save all settings to ini file
echo [Settings] > "%SETTINGS_PATH%"
echo SelectedTerminal=%SELECTED_TERMINAL% >> "%SETTINGS_PATH%"
echo TerminalHeightPercent=%TERMINAL_HEIGHT% >> "%SETTINGS_PATH%"
echo HideOnFocusLost=%HIDE_ON_FOCUS_LOST% >> "%SETTINGS_PATH%"

REM Create AutoHotkey startup shortcut
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%AHK_SHORTCUT_PATH%'); $s.TargetPath = '%AHK_SCRIPT_PATH%'; $s.Save()"

echo Setup complete. Selected terminal: %SELECTED_TERMINAL%
pause
