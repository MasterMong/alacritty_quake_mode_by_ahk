#SingleInstance Force
SetWorkingDir %USERPROFILE%

; Terminal configurations
global terminals := {}
terminals.wezterm := { path: "C:\Program Files\WezTerm\wezterm-gui.exe"
                    , title: "ahk_class org.wezfurlong.wezterm ahk_exe wezterm-gui.exe" }
terminals.alacritty := { path: "C:\Program Files\Alacritty\alacritty.exe"
                      , title: "ahk_exe alacritty.exe" }

; Read all settings from INI file
settingsFile := A_ScriptDir . "\terminal_settings.ini"
global selectedTerminal := ReadSetting("SelectedTerminal", "wezterm")
global terminalPath := terminals[selectedTerminal].path
global terminalTitle := terminals[selectedTerminal].title
global terminalHeightPercent := ReadSetting("TerminalHeightPercent", "100")
global hideOnFocusLost := ReadSetting("HideOnFocusLost", "false")
global isVisible := WinExist(terminalTitle) ? true : false  ; Initialize visibility state

ReadSetting(key, defaultValue) {
    global settingsFile
    IniRead, value, %settingsFile%, Settings, %key%, %defaultValue%
    return value
}

; Replace old ReadOrSelectTerminal with UpdateTerminal
UpdateTerminal(newTerminal) {
    global settingsFile, selectedTerminal, terminalPath, terminalTitle, terminals
    selectedTerminal := newTerminal
    terminalPath := terminals[selectedTerminal].path
    terminalTitle := terminals[selectedTerminal].title
    IniWrite, %selectedTerminal%, %settingsFile%, Settings, SelectedTerminal
}

; Update terminal switch hotkey
#+`::
    MsgBox, 4, Change Terminal, Would you like to switch to the other terminal?
    IfMsgBox Yes
    {
        newTerminal := (selectedTerminal = "wezterm") ? "alacritty" : "wezterm"
        UpdateTerminal(newTerminal)
        MsgBox, Terminal changed to %selectedTerminal%. Changes will take effect on next toggle.
    }
return

; Win + ~ to start Alacritty
#`:: 
    selectedTerminal := "alacritty"
    terminalPath := terminals[selectedTerminal].path
    terminalTitle := terminals[selectedTerminal].title
    if (!WinExist(terminalTitle)) {
        Run, %terminalPath%
        WinWait, %terminalTitle%
        Sleep, 100
        SetupTerminal()
        isVisible := true
    } else {
        ToggleTerminalVisibility()
    }
return

; Win + Enter to start WezTerm in normal mode
#Enter::
    selectedTerminal := "wezterm"
    terminalPath := terminals[selectedTerminal].path
    terminalTitle := terminals[selectedTerminal].title
    
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
    
    if (selectedTerminal = "wezterm") {
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
        ; Alacritty handling
        WinSet, Style, -0xC00000, %terminalTitle%
        WinSet, Style, -0x40000, %terminalTitle%
        WinMove, %terminalTitle%, , WorkAreaLeft, WorkAreaTop, workAreaWidth, desiredHeight
    }
    
    ; Ensure window is on top
    WinSet, AlwaysOnTop, On, %terminalTitle%
}

; Function to toggle terminal visibility
ToggleTerminalVisibility() {
    if (isVisible) {
        if (selectedTerminal = "wezterm") {
            ; Store window position before hiding
            WinGetPos, lastX, lastY, lastW, lastH, %terminalTitle%
        }
        WinHide, %terminalTitle%
        isVisible := false
    } else {
        WinShow, %terminalTitle%
        WinActivate, %terminalTitle%
        if (selectedTerminal = "wezterm") {
            ; Restore last position and force redraw
            WinMove, %terminalTitle%, , lastX, lastY, lastW, lastH
            Sleep, 10
        }
        SetupTerminal()
        isVisible := true
    }
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