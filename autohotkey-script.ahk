#SingleInstance Force
SetWorkingDir %USERPROFILE%

; Terminal configurations
global terminals := {}
terminals.wezterm := { path: "C:\Program Files\WezTerm\wezterm-gui.exe"
                    , title: "ahk_exe wezterm-gui.exe" }
terminals.alacritty := { path: "C:\Program Files\Alacritty\alacritty.exe"
                      , title: "ahk_exe alacritty.exe" }

; Read settings or show selection dialog
global selectedTerminal := ReadOrSelectTerminal()
global terminalPath := terminals[selectedTerminal].path
global terminalTitle := terminals[selectedTerminal].title

; Rest of the configuration
global isVisible := false
global terminalHeightPercent := 100
global hideOnFocusLost := false

ReadOrSelectTerminal() {
    settingsFile := A_ScriptDir . "\terminal_settings.ini"
    IniRead, selected, %settingsFile%, Settings, SelectedTerminal, none
    
    if (selected = "none") {
        MsgBox, 4, Terminal Selection, Would you like to use WezTerm?`nYes = WezTerm`nNo = Alacritty
        IfMsgBox Yes
            selected := "wezterm"
        else
            selected := "alacritty"
        
        IniWrite, %selected%, %settingsFile%, Settings, SelectedTerminal
    }
    
    return selected
}

; To change terminal later, add this hotkey
#+`::
    MsgBox, 4, Change Terminal, Would you like to switch to the other terminal?
    IfMsgBox Yes
    {
        if (selectedTerminal = "wezterm")
            selectedTerminal := "alacritty"
        else
            selectedTerminal := "wezterm"
            
        terminalPath := terminals[selectedTerminal].path
        terminalTitle := terminals[selectedTerminal].title
        
        settingsFile := A_ScriptDir . "\terminal_settings.ini"
        IniWrite, %selectedTerminal%, %settingsFile%, Settings, SelectedTerminal
        
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