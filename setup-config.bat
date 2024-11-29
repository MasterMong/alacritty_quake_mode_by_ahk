@echo off
setlocal EnableDelayedExpansion

REM Check for admin privileges and elevate if needed
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~dpnx0' -Verb RunAs"
    exit /b
)

REM Set common paths
set CONFIG_ROOT=%~dp0
set AHK_SCRIPT_PATH=%CONFIG_ROOT%autohotkey-script.ahk
set AHK_SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-script.lnk
set SETTINGS_PATH=%CONFIG_ROOT%terminal_settings.ini

REM Terminal-specific paths
set WEZTERM_DIR=%USERPROFILE%\.config\wezterm
set ALACRITTY_DIR=%APPDATA%\alacritty
set WEZTERM_CONFIG=%WEZTERM_DIR%\wezterm.lua
set ALACRITTY_CONFIG=%ALACRITTY_DIR%\alacritty.toml

echo Terminal Configuration Setup
echo --------------------------
echo 1. Setting up directories...

REM Create config directories with proper permissions
mkdir "%WEZTERM_DIR%" 2>nul
icacls "%WEZTERM_DIR%" /grant:r "%USERNAME%":(OI)(CI)F /T

mkdir "%ALACRITTY_DIR%" 2>nul
icacls "%ALACRITTY_DIR%" /grant:r "%USERNAME%":(OI)(CI)F /T

echo 2. Copying configuration files...
copy /Y "%CONFIG_ROOT%wezterm.lua" "%WEZTERM_CONFIG%" || (
    echo Error copying WezTerm config. Retrying with elevated privileges...
    powershell -Command "Copy-Item -Path '%CONFIG_ROOT%wezterm.lua' -Destination '%WEZTERM_CONFIG%' -Force"
)
copy /Y "%CONFIG_ROOT%alacritty.toml" "%ALACRITTY_CONFIG%"

echo 3. Configuring settings...

REM Configure settings
choice /C YN /N /M "Hide terminal when focus is lost? (Y/N): "
if errorlevel 2 (
    set HIDE_ON_FOCUS_LOST=false
) else (
    set HIDE_ON_FOCUS_LOST=true
)

set /P TERMINAL_HEIGHT="Enter terminal height percentage (1-100) [default=100]: "
if "%TERMINAL_HEIGHT%"=="" set TERMINAL_HEIGHT=100

REM Save settings to ini file
echo [Settings] > "%SETTINGS_PATH%"
echo TerminalHeightPercent=%TERMINAL_HEIGHT% >> "%SETTINGS_PATH%"
echo HideOnFocusLost=%HIDE_ON_FOCUS_LOST% >> "%SETTINGS_PATH%"

echo 4. Setting up AutoHotkey startup...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%AHK_SHORTCUT_PATH%'); $s.TargetPath = '%AHK_SCRIPT_PATH%'; $s.Save()"

echo Setup complete!
echo - Press Win + ~ to toggle Alacritty in Quake mode
echo - Press Win + Enter to open WezTerm in normal mode
pause
