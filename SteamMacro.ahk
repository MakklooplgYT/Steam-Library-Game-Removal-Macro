
#Requires AutoHotkey v2.0
#SingleInstance Force

folder := "C:\Users\JustMark\Downloads\Steam Macro"
captureScript := folder "\capture.ps1"
findScript := folder "\find-target.ps1"
resultFile := folder "\target.txt"

running := false
busy := false
cycles := 0
clickDelay := 20
finalDelay := 150
confirmDelay := 20

; ---------- GUI ----------
mainGui := Gui("+AlwaysOnTop", "Steam Macro")
mainGui.BackColor := "17191F"
mainGui.SetFont("s10 cE6EAF2", "Segoe UI")

mainGui.AddText("x22 y18 w330 h32 c66C0F4", "STEAM MACRO")
mainGui.AddText("x23 y51 w330 h22 c969EAD", "LIBRARY AUTOMATION")

mainGui.AddText("x23 y88 w320 h1 0x10")
statusText := mainGui.AddText("x23 y103 w320 h25 cF0B84D", "● STOPPED")
cycleText := mainGui.AddText("x23 y130 w320 h22 cB8BBC7", "Cycles completed: 0")

startBtn := mainGui.AddButton("x23 y165 w155 h38", "START  [F6]")
stopBtn := mainGui.AddButton("x190 y165 w155 h38", "STOP  [F7]")

mainGui.AddText("x23 y220 w320 h24 c66C0F4", "CLICK TIMING")

mainGui.AddText("x23 y255 w220 h24 cB8BBC7", "Between clicks (ms)")
clickInput := mainGui.AddEdit("x260 y251 w80 h28 Center", "20")

mainGui.AddText("x23 y295 w225 h24 cB8BBC7", "Before final Remove (ms)")
finalInput := mainGui.AddEdit("x260 y291 w80 h28 Center", "150")

mainGui.AddText("x23 y335 w225 h24 cB8BBC7", "After confirmation (ms)")
confirmInput := mainGui.AddEdit("x260 y331 w80 h28 Center", "20")

mainGui.AddText("x23 y375 w320 h1 0x10")
mainGui.AddText("x23 y390 w320 h22 c66C0F4", "ACTIVITY LOG")

logEdit := mainGui.AddEdit(
    "x23 y418 w322 h130 ReadOnly -Wrap +VScroll Background20232B cD8DAE3",
    "Ready. Press START or F6."
)

mainGui.AddText("x23 y565 w320 h20 c858A98", "F6 Start  |  F7 Stop  |  Esc Exit")

; Set dark edit colors explicitly
for ctrl in [clickInput, finalInput, confirmInput, logEdit] {
    ctrl.Opt("Background20232B cE6EAF2")
}

startBtn.OnEvent("Click", StartMacro)
stopBtn.OnEvent("Click", StopMacro)
mainGui.OnEvent("Close", (*) => ExitApp())
mainGui.OnEvent("Escape", (*) => ExitApp())

mainGui.Show("w370 h605")

F6::StartMacro()
F7::StopMacro()
Esc::ExitApp()

StartMacro(*) {
    global running, clickDelay, finalDelay, confirmDelay

    if running
        return

    clickDelay := ReadDelay(clickInput, 20)
    finalDelay := ReadDelay(finalInput, 150)
    confirmDelay := ReadDelay(confirmInput, 20)

    running := true
    statusText.Opt("c4ADE80")
    statusText.Value := "● RUNNING"
    AddLog("Macro started.")
    SetTimer RunCycle, -10
}

StopMacro(*) {
    global running

    running := false
    statusText.Opt("cF0B84D")
    statusText.Value := "● STOPPED"
    AddLog("Stop requested.")
}

ReadDelay(control, fallback) {
    value := Trim(control.Value)
    if !RegExMatch(value, "^\d+$")
        return fallback
    return Min(Integer(value), 5000)
}

AddLog(message) {
    global logEdit
    timestamp := FormatTime(, "HH:mm:ss")
    logEdit.Value .= "`r`n[" timestamp "] " message
    SendMessage(0x115, 7, 0, logEdit.Hwnd)
}

RunCycle() {
    global running, busy, cycles

    if !running || busy
        return

    busy := true
    success := false

    try {
        success := DoRemoval()
    } catch as err {
        AddLog("Error: " err.Message)
    }

    busy := false

    if success {
        cycles += 1
        cycleText.Value := "Cycles completed: " cycles
        AddLog("Cycle completed.")
    }

    if running
        SetTimer RunCycle, -20
}

DoRemoval() {
    global folder, captureScript, findScript, resultFile
    global running, clickDelay, finalDelay, confirmDelay

    if !running
        return false

    Click 441, 444, "Right"
    Sleep clickDelay
    if !running
        return false

    Click 497, 564
    Sleep clickDelay
    if !running
        return false

    RunWait(
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' captureScript '"',
        ,
        "Hide"
    )

    if !running || !FileExist(folder "\crop.png")
        return false

    try FileDelete resultFile

    code := RunWait(
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' findScript '"',
        ,
        "Hide"
    )

    if !running || code != 0 || !FileExist(resultFile)
        return false

    coords := FileRead(resultFile)
    if !RegExMatch(coords, "(\d+)\s+(\d+)", &m)
        return false

    x := Integer(m[1])
    y := Integer(m[2])

    MouseMove x, y, 0
    Sleep clickDelay
    if !running
        return false

    Click x, y
    Sleep finalDelay
    if !running
        return false

    Click 2029, 876
    Sleep confirmDelay

    return true
}
