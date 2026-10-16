
#Requires AutoHotkey v2.0
#SingleInstance Force

folder := "C:\Users\JustMark\Downloads\Steam Macro"
captureScript := folder "\capture.ps1"
findScript := folder "\find-target.ps1"
resultFile := folder "\target.txt"

running := false
busy := false

F6::{
    global running
    if running
        return
    running := true
    SetTimer RunCycle, -10
}

F7::ExitApp
Esc::ExitApp

RunCycle() {
    global running, busy

    if !running || busy
        return

    busy := true
    try {
        DoRemoval()
    } catch {
    }
    busy := false

    if running
        SetTimer RunCycle, -20
}

DoRemoval() {
    global folder, captureScript, findScript, resultFile, running

    if !running
        return

    Click 441, 444, "Right"
    Sleep 20
    if !running
        return

    Click 497, 564
    Sleep 20
    if !running
        return

    RunWait(
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' captureScript '"',
        ,
        "Hide"
    )

    if !running || !FileExist(folder "\crop.png")
        return

    try FileDelete resultFile

    code := RunWait(
        'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "' findScript '"',
        ,
        "Hide"
    )

    if !running || code != 0 || !FileExist(resultFile)
        return

    coords := FileRead(resultFile)

    if !RegExMatch(coords, "(\d+)\s+(\d+)", &m)
        return

    x := Integer(m[1])
    y := Integer(m[2])

    MouseMove x, y, 0
    Sleep 20
    if !running
        return

    Click x, y
    Sleep 150
    if !running
        return

    Click 2029, 876
    Sleep 20
}
