#SingleInstance Force
SetWorkingDir %USERPROFILE%

; Terminal configurations
global terminals := {}
terminals.wezterm := { path: "C:\Program Files\WezTerm\wezterm-gui.exe"
                    , title: "ahk_exe wezterm-gui.exe" }
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

; Win + Enter to toggle terminal (# represents the Windows key)
#`::
    if (!WinExist(terminalTitle)) {
        Run, %terminalPath%
        WinWait, %terminalTitle%
        Sleep, 100
        SetupTerminal()
        isVisible := true
    } else {
        if (isVisible) {
            WinGet, style, Style, %terminalTitle%
            isVisible := style & 0x10000000  ; Check if window is visible
        }
        ToggleTerminalVisibility()
    }
return

; Function to set up terminal window position and size
SetupTerminal() {
    ; Get the work area (screen space without taskbar)
    SysGet, WorkArea, MonitorWorkArea
    
    ; Calculate dimensions
    workAreaWidth := WorkAreaRight - WorkAreaLeft
    workAreaHeight := WorkAreaBottom - WorkAreaTop
    
    ; Calculate desired height as a percentage of the work area height
    desiredHeight := workAreaHeight * (terminalHeightPercent / 100)
    
    ; Remove window borders and set size/position
    WinSet, Style, -0xC00000, %terminalTitle%  ; Remove title bar
    WinSet, Style, -0x40000, %terminalTitle%   ; Remove border/sizing
    
    ; Position window in work area (excludes taskbar)
    WinMove, %terminalTitle%, , WorkAreaLeft, WorkAreaTop, workAreaWidth, desiredHeight
    
    ; Ensure window is on top
    WinSet, AlwaysOnTop, On, %terminalTitle%
}

; Function to toggle terminal visibility
ToggleTerminalVisibility() {
    if (isVisible) {
        WinHide, %terminalTitle%
        isVisible := false
    } else {
        WinShow, %terminalTitle%
        WinActivate, %terminalTitle%
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