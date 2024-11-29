#SingleInstance Force
SetWorkingDir %USERPROFILE%

; Terminal configurations
global terminals := {}
terminals.wezterm := { path: "C:\Program Files\WezTerm\wezterm-gui.exe"
                    , title: "ahk_class org.wezfurlong.wezterm ahk_exe wezterm-gui.exe" }
terminals.alacritty := { path: "C:\Program Files\Alacritty\alacritty.exe"
                      , title: "ahk_exe alacritty.exe"
                      , pid: 0 }  ; Track Alacritty PID

; Read settings from INI file
settingsFile := A_ScriptDir . "\terminal_settings.ini"
global terminalHeightPercent := ReadSetting("TerminalHeightPercent", "100")
global hideOnFocusLost := ReadSetting("HideOnFocusLost", "false")
global isVisible := false

ReadSetting(key, defaultValue) {
    global settingsFile
    IniRead, value, %settingsFile%, Settings, %key%, %defaultValue%
    return value
}

; Win + ~ to start Alacritty
#`:: 
    terminalPath := terminals.alacritty.path
    terminalTitle := terminals.alacritty.title
    
    DetectHiddenWindows, On
    if (terminals.alacritty.pid) {
        if (WinExist("ahk_pid " . terminals.alacritty.pid)) {
            ToggleTerminalVisibility()
        } else {
            ; Previous instance no longer exists, start new one
            terminals.alacritty.pid := 0
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
        isVisible := true
    }
    DetectHiddenWindows, Off
return

; Win + Enter to start WezTerm in normal mode
#Enter::
    terminalPath := terminals.wezterm.path
    terminalTitle := terminals.wezterm.title
    
    DetectHiddenWindows, On
    SetTitleMatchMode, 2
    
    if (!WinExist(terminalTitle)) {
        Run, %terminalPath%
        WinWait, %terminalTitle%,, 10
    }
    WinShow, %terminalTitle%
    WinActivate, %terminalTitle%
    DetectHiddenWindows, Off
return

; Function to set up terminal window position and size
SetupTerminal() {
    ; Get the work area (screen space without taskbar)
    SysGet, WorkArea, MonitorWorkArea
    
    ; Calculate dimensions
    workAreaWidth := WorkAreaRight - WorkAreaLeft
    workAreaHeight := WorkAreaBottom - WorkAreaTop
    desiredHeight := workAreaHeight * (terminalHeightPercent / 100)
    
    if (terminalTitle = terminals.wezterm.title) {
        ; WezTerm specific handling
        WinSet, Style, -0x80000, %terminalTitle%  ; Remove minimize/maximize buttons
        WinSet, Style, -0x40000, %terminalTitle%  ; Remove sizing border
        WinSet, Style, -0xC00000, %terminalTitle% ; Remove title bar
        WinMove, %terminalTitle%, , WorkAreaLeft, WorkAreaTop, workAreaWidth, desiredHeight
        
        ; Force redraw to prevent visual glitches
        WinHide, %terminalTitle%
        Sleep, 10
        WinShow, %terminalTitle%
    } else {
        ; Alacritty handling - use PID for precise window control
        targetWindow := "ahk_pid " . terminals.alacritty.pid
        WinSet, Style, -0xC00000, %targetWindow%
        WinSet, Style, -0x40000, %targetWindow%
        WinMove, %targetWindow%, , WorkAreaLeft, WorkAreaTop, workAreaWidth, desiredHeight
        WinSet, AlwaysOnTop, On, %targetWindow%
    }
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

; Optional: Hide terminal when focus is lost
#if WinActive(terminalTitle) and hideOnFocusLost
~LButton::
    MouseGetPos,,, WindowUnderMouse
    if (WinExist(terminalTitle) and WindowUnderMouse != WinExist(terminalTitle)) {
        WinHide, %terminalTitle%
        isVisible := false
    }
return

; Clean up on script exit
OnExit(func("ExitFunc"))

ExitFunc() {
    if (terminals.alacritty.pid) {
        Process, Close, % terminals.alacritty.pid
    }
}