@echo off

REM Set paths
set AHK_SCRIPT_PATH=%~dp0autohotkey-script.ahk
set AHK_SHORTCUT_PATH=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\autohotkey-script.lnk
set ALACRITTY_CONFIG_PATH=%APPDATA%\alacritty\alacritty.toml

REM Create alacritty config directory if it doesn't exist
if not exist %APPDATA%\alacritty (
    mkdir %APPDATA%\alacritty
)

REM Check if the alacritty config directory was created successfully
if exist %APPDATA%\alacritty (
    REM Copy alacritty.toml to the config directory
    copy /Y "%~dp0alacritty.toml" "%ALACRITTY_CONFIG_PATH%"
) else (
    echo Failed to create alacritty config directory.
    pause
    exit /b 1
)

REM Create a shortcut for autohotkey-script.ahk in the startup folder
powershell -command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%AHK_SHORTCUT_PATH%'); $s.TargetPath = '%AHK_SCRIPT_PATH%'; $s.Save()"

echo Setup complete.
pause
