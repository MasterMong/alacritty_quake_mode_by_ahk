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

REM Terminate existing AutoHotkey script
taskkill /F /IM "autohotkey.exe" /FI "WINDOWTITLE eq autohotkey-script.ahk" 2>nul
timeout /t 1 /nobreak >nul

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

echo 3. Configuring Terminal Settings...

REM Configure Alacritty settings
choice /C YN /N /M "Hide Alacritty when focus is lost? (Y/N): "
if errorlevel 2 (
    set ALACRITTY_HIDE_ON_LOST_FOCUS=false
) else (
    set ALACRITTY_HIDE_ON_LOST_FOCUS=true
)

choice /C YN /N /M "Hide WezTerm when focus is lost? (Y/N): "
if errorlevel 2 (
    set WEZTERM_HIDE_ON_LOST_FOCUS=false
) else (
    set WEZTERM_HIDE_ON_LOST_FOCUS=true
)

set /P ALACRITTY_QUAKE_HEIGHT="Enter Alacritty Quake mode height percentage (1-100) [default=80]: "
if "%ALACRITTY_QUAKE_HEIGHT%"=="" set ALACRITTY_QUAKE_HEIGHT=80

REM Save settings to ini file
echo [Settings] > "%SETTINGS_PATH%"
echo AlacrittyQuakeHeight=%ALACRITTY_QUAKE_HEIGHT% >> "%SETTINGS_PATH%"
echo AlacrittyHideOnLostFocus=%ALACRITTY_HIDE_ON_LOST_FOCUS% >> "%SETTINGS_PATH%"
echo WeztermHideOnLostFocus=%WEZTERM_HIDE_ON_LOST_FOCUS% >> "%SETTINGS_PATH%"

echo 4. Setting up AutoHotkey startup...
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%AHK_SHORTCUT_PATH%'); $s.TargetPath = '%AHK_SCRIPT_PATH%'; $s.Save()"

echo 5. Restarting AutoHotkey script...
start "" "%AHK_SCRIPT_PATH%"

echo Setup complete!
echo - Press Win + ~ to toggle Alacritty in Quake mode
echo - Press Win + Enter to open WezTerm in normal mode
pause
