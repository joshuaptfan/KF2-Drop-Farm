Set WshShell = WScript.CreateObject("WScript.Shell")
If Instr(1, WScript.FullName, "CScript", vbTextCompare) = 0 Then
    WshShell.Run "cscript //nologo """ & WScript.ScriptFullName & """", 1, False
    WScript.Quit
End If

Dim dblInactiveWait, intCustomWait, intGameLoadWait, intMapLoadWait, boolCustomIdle



'///////////// USER VARIABLES /////////////

' Time to wait for game to load in seconds
intGameLoadWait = 40

' Time to wait for map to load in seconds
intMapLoadWait = 8

'///////////// USER VARIABLES /////////////



WScript.Echo "Killing Floor 2 drop farming script"
WScript.Echo "Author: /u/killall-q"
WScript.Echo
WScript.Echo "Close this console window to exit the script."
WScript.Echo
WScript.Echo "//////////// USER INPUT REQUIRED ////////////"
Do
    WScript.Echo
    WScript.Echo "Select one of the following:"
    WScript.Echo "[1] Normal        Collect drop every 12 hours"
    WScript.Echo "[2] Event         Collect drop every 3.5 hours"
    WScript.Echo "[3] Event 2XP     Collect drop every 2 hours"
    WScript.StdOut.Write "Selection: "
    Dim strMode
    strMode = WScript.StdIn.ReadLine
    Select Case strMode
        Case "1"
            dblInactiveWait = 11.5
            Exit Do
        Case "2"
            dblInactiveWait = 3
            Exit Do
        Case "3"
            dblInactiveWait = 1.5
            Exit Do
        Case Else
            WScript.Echo
            WScript.Echo "ERROR: Invalid selection"
    End Select
Loop
WScript.Echo
WScript.Echo "You are eligible for drops " & dblInactiveWait + 0.5 & " hours after your last drop."
WScript.StdOut.Write "Minutes to wait before first run (not including idle time)? [number]: "
intCustomWait = WScript.StdIn.ReadLine
If Not IsNumeric(intCustomWait) Then
    intCustomWait = 0
End If
WScript.Echo
WScript.Echo "KF2 must run for 30 consecutive minutes before you are eligible for the next drop."
WScript.StdOut.Write "Idle KF2 for 30 minutes before first run? [Y/N]: "
If LCase(WScript.StdIn.ReadLine) = "n" Then
    boolCustomIdle = False
Else
    boolCustomIdle = True
End If
WScript.Echo
WScript.Echo "////////////  END OF USER INPUT  ////////////"
WScript.Echo
WScript.Echo "Thank you, you may now leave the computer."
WScript.Echo "Disable sleep and hibernation settings."
WScript.Echo "You can continue to use the computer while the script is running."
WScript.Echo

WaitMin(intCustomWait)
StartKF2
If boolCustomIdle = True Then
    WaitMin(30)
    PopUpWarn
    StartKF2
End If
CollectItemDrop
WaitInactive
Do
    StartKF2
    WaitMin(30)
    PopUpWarn
    StartKF2
    CollectItemDrop
    WaitInactive
Loop



Sub StartKF2
    WScript.Echo
    WScript.Echo Now
    For Each process in GetObject("winmgmts:").InstancesOf("Win32_Process")
        If StrComp(process.Name, "KFGame.exe", vbTextCompare) = 0 Then
            WScript.Echo "Killing Floor 2 is already running"
            Exit Sub
        End If
    Next
    WScript.Echo "Starting Killing Floor 2"
    WshShell.Run "C:\PROGRA~2\Steam\Steam.exe -applaunch 232090 -nostartupmovies"
    WScript.Sleep intGameLoadWait * 1000
End Sub

Sub PopUpWarn
    WshShell.Popup "Please switch to Killing Floor 2, then do not touch the mouse or keyboard.", 10, "KF2 Drop Farm"
End Sub

Sub CollectItemDrop
    For Each process in GetObject("winmgmts:").InstancesOf("Win32_Process")
        If StrComp(process.Name, "KFGame.exe", vbTextCompare) = 0 Then
            objKF2Process = process.ProcessId
            Exit For
        End If
    Next
    ' Focus KF2 window
    WshShell.AppActivate objKF2Process
    ' Open KF-Farmhouse
    WScript.Echo "Opening map KF-Farmhouse"
    WshShell.SendKeys "{F3}open KF-Farmhouse{ENTER}"
    WScript.Sleep 1000
    ' Press Ready Up
    WshShell.AppActivate objKF2Process
    WScript.Echo "Pressing Ready Up"
    WshShell.SendKeys "{F3}startfire{ENTER}"
    WScript.Sleep intMapLoadWait * 1000
    ' Suicide
    WshShell.AppActivate objKF2Process
    WScript.Echo "Suiciding"
    WshShell.SendKeys "{F3}suicide{ENTER}"
    WScript.Sleep 20000
    ' Quit game
    WshShell.AppActivate objKF2Process
    WScript.Echo "Quitting game"
    WshShell.SendKeys "{F3}exit{ENTER}"
End Sub

Function WaitMin(intMin)
    If intMin > 0 Then
        WScript.Echo
        WScript.Echo "Waiting for " & intMin & " minutes"
    End If
    WScript.Sleep intMin * 60000
End Function

Sub WaitInactive
    WScript.Echo "Waiting for " & dblInactiveWait & " hours"
    WScript.Sleep dblInactiveWait * 3600000 - intGameLoadWait * 1000
End Sub
