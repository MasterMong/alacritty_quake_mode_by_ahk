#SingleInstance Force
SetWorkingDir %USERPROFILE%

; Configuration
global terminalPath := "C:\Program Files\Alacritty\alacritty.exe"
global terminalTitle := "ahk_exe alacritty.exe"
global isVisible := false
global terminalHeightPercent := 100  ; Set terminal height as a percentage of screen height
global hideOnFocusLost := false  ; Set to true to hide terminal when focus is lost

; Win + Enter to toggle terminal (# represents the Windows key)
#Enter::
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