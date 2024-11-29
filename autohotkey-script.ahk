#SingleInstance Force
SetWorkingDir %USERPROFILE%

; Terminal configurations
global terminals := {}
terminals.wezterm := { path: "C:\Program Files\WezTerm\wezterm-gui.exe"
                    , title: "ahk_class org.wezfurlong.wezterm ahk_exe wezterm-gui.exe"
                    , isVisible: false
                    , config: { hideOnLostFocus: ReadSetting("WeztermHideOnLostFocus", "false") } }
terminals.alacritty := { path: "C:\Program Files\Alacritty\alacritty.exe"
                      , title: "ahk_exe alacritty.exe"
                      , pid: 0
                      , isVisible: false
                      , isQuake: true
                      , config: { quakeHeight: ReadSetting("AlacrittyQuakeHeight", "80")
                              , hideOnLostFocus: ReadSetting("AlacrittyHideOnLostFocus", "false") } }

; Read settings from INI file
settingsFile := A_ScriptDir . "\terminal_settings.ini"
global quakeConfig := { heightPercent: ReadSetting("QuakeHeightPercent", "100")
                     , hideOnFocusLost: ReadSetting("QuakeHideOnFocusLost", "false") }

ReadSetting(key, defaultValue) {
    global settingsFile
    IniRead, value, %settingsFile%, Settings, %key%, %defaultValue%
    if (InStr(key, "HideOnLostFocus"))
        return (value = "true" || value = "1")
    return value
}

; Win + ~ to start Alacritty
#`:: 
    terminalPath := terminals.alacritty.path
    terminalTitle := terminals.alacritty.title
    
    DetectHiddenWindows, On
    if (terminals.alacritty.pid) {
        if (WinExist("ahk_pid " . terminals.alacritty.pid)) {
            if (terminals.alacritty.isVisible) {
                WinHide, % "ahk_pid " . terminals.alacritty.pid
                terminals.alacritty.isVisible := false
            } else {
                WinShow, % "ahk_pid " . terminals.alacritty.pid
                WinActivate, % "ahk_pid " . terminals.alacritty.pid
                SetupTerminal()
                terminals.alacritty.isVisible := true
            }
        } else {
            terminals.alacritty.pid := 0
            terminals.alacritty.isVisible := false
        }
    }
    
    if (!terminals.alacritty.pid) {
        Run, %terminalPath%,, Hide, launchedPID
        terminals.alacritty.pid := launchedPID
        WinWait, ahk_pid %launchedPID%
        Sleep, 100
        SetupTerminal()
        WinShow, ahk_pid %launchedPID%
        WinActivate, ahk_pid %launchedPID%
        terminals.alacritty.isVisible := true
    }
    DetectHiddenWindows, Off
return

; Win + Enter to start/toggle WezTerm
#Enter::
    terminalPath := terminals.wezterm.path
    terminalTitle := terminals.wezterm.title
    
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    
    if (!WinExist(terminalTitle)) {
        Run, %terminalPath%
        WinWait, %terminalTitle%,, 10
        terminals.wezterm.isVisible := true
    } else {
        if (terminals.wezterm.isVisible) {
            WinHide, %terminalTitle%
            terminals.wezterm.isVisible := false
        } else {
            WinShow, %terminalTitle%
            WinActivate, %terminalTitle%
            terminals.wezterm.isVisible := true
        }
    }
    DetectHiddenWindows, Off
return

; Function to set up terminal window position and size
SetupTerminal() {
    ; Get the work area (screen space without taskbar)
    SysGet, WorkArea, MonitorWorkArea
    
    ; Calculate dimensions
    workAreaWidth := WorkAreaRight - WorkAreaLeft
    workAreaHeight := WorkAreaBottom - WorkAreaTop
    desiredHeight := workAreaHeight * (terminals.alacritty.config.quakeHeight / 100)
    
    ; Only apply Quake-mode styling to Alacritty
    targetWindow := "ahk_pid " . terminals.alacritty.pid
    WinSet, Style, -0xC00000, %targetWindow%
    WinSet, Style, -0x40000, %targetWindow%
    WinMove, %targetWindow%, , WorkAreaLeft, WorkAreaTop, workAreaWidth, desiredHeight
    WinSet, AlwaysOnTop, On, %targetWindow%
}

; Function to toggle terminal visibility
ToggleTerminalVisibility() {
    DetectHiddenWindows, On
    targetWindow := (terminalTitle = terminals.alacritty.title) 
        ? "ahk_pid " . terminals.alacritty.pid 
        : terminalTitle

    if (!WinExist(targetWindow)) {
        ; Window no longer exists, reset state
        isVisible := false
        if (terminalTitle = terminals.alacritty.title) {
            terminals.alacritty.pid := 0
        }
        DetectHiddenWindows, Off
        return
    }

    if (isVisible) {
        WinHide, %targetWindow%
        isVisible := false
    } else {
        WinShow, %targetWindow%
        WinActivate, %targetWindow%
        SetupTerminal()
        isVisible := true
    }
    DetectHiddenWindows, Off
}

; Optional: Hide terminals when focus is lost
#if
~LButton::
    MouseGetPos,,, WindowUnderMouse
    DetectHiddenWindows, On
    
    ; Handle Alacritty focus loss
    if (terminals.alacritty.config.hideOnLostFocus && terminals.alacritty.pid) {
        alacrittyWin := "ahk_pid " . terminals.alacritty.pid
        if (WinExist(alacrittyWin) && WindowUnderMouse != WinExist(alacrittyWin)) {
            WinHide, %alacrittyWin%
            terminals.alacritty.isVisible := false
        }
    }
    
    ; Handle WezTerm focus loss
    if (terminals.wezterm.config.hideOnLostFocus) {
        if (WinExist(terminals.wezterm.title) && WindowUnderMouse != WinExist(terminals.wezterm.title)) {
            WinHide, % terminals.wezterm.title
            terminals.wezterm.isVisible := false
        }
    }
    
    DetectHiddenWindows, Off
return

; Clean up on script exit
OnExit(func("ExitFunc"))

ExitFunc() {
    if (terminals.alacritty.pid) {
        Process, Close, % terminals.alacritty.pid
    }
}