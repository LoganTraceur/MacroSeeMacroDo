;-----------------------------------
; Macro Recorder v2.1  By FeiYue https://www.autohotkey.com/boards/viewtopic.php?t=34184&p=159538
;
;  Description: This script records the mouse
;  and keyboard actions and then plays back.
;
;  F1  -->  Record(Screen) (CoordMode, Mouse, Screen)
;  F2  -->  Record(Window) (CoordMode, Mouse, Window)
;  F3  -->  Stop   Record/Play
;  F4  -->  Play   LogFile
;  F5  -->  Edit   LogFile
;  F6  -->  Pause  Record/Play
;
;  Note:
;  1. press the Ctrl button individually
;     to record the movement of the mouse.
;  2. Shake the mouse on the Pause button,
;     you can pause recording or playback.
;-----------------------------------
#NoEnv
SetBatchLines, -1
Thread, NoTimers
CoordMode, ToolTip
SetTitleMatchMode, 2
DetectHiddenWindows, On
;--------------------------
LogFile:=A_Temp . "\OneKey_MacroFile.txt"                       ;C:\Users\<UserName>\AppData\Local\Temp
UsedKeys:= "F24" ; Dont Record These
Play_Title:=RegExReplace(LogFile,".*\\") " ahk_class AutoHotkey"
;--------------------------
; Setup Menu
#Persistent  ; Keep the script running until the user exits it.
Menu, Tray, Add  ; Creates a separator line.
Menu, Tray, Add, Print macroRunsRemaining, MenuHandler_PrintmacroRunsRemaining
Menu, Tray, Add, Send Hotkey for Binding, MenuHandler_Send      ; Creates a new menu item.
Menu, Tray, Add, Edit Macro, Edit  ; Open Notepad File
Menu, Tray, Add, About OneKey Instant Macro, MenuHandler_About  ; Creates a new menu item.
;--------------------------
; Global Variables
macroRunsRemaining := 0                                         ; Keep track of how many times to run the macro
;--------------------------
Gui, +AlwaysOnTop -Caption +ToolWindow +E0x08000000 +Hwndgui_id
Gui, Margin, 0, 0
Gui, Font, s12
s:="[F1]Record(Screen),[F2]Record(Window),"
  . "[F3]Stop,[F4]Play,[F5]Edit,[F6] Pause "
;For i,v in StrSplit(s, ",")
;{
;  j:=i=1 ? "":"x+0", j.=InStr(v,"Pause") ? " vPause":""
;  Gui, Add, Button, %j% gRun, %v%
;}
Gui, Add, Button, x+0 w0 Hidden vMyText
Gui, Show, NA y0, Macro Recorder
OnMessage(0x200,"WM_MOUSEMOVE")
;--------------------------
SetTimer, OnTop, 2000
OnTop:
    Gui, +AlwaysOnTop
return

Run:
    if IsLabel(k:=RegExReplace(RegExReplace(A_GuiControl,".*]"),"\W"))
        Goto, %k%
return

WM_MOUSEMOVE() {
    static OK_Time
    ListLines, Off
    if (A_Gui=1) and (A_GuiControl="Pause")
        and (t:=A_TickCount)>OK_Time
    {
        OK_Time:=t+500
        Gosub, Pause
    }
}

ShowTip(s:="", pos:="y35", color:="Red|00FFFF") {
    static bak, idx
    if (bak=color "," pos "," s)
        return
    bak:=color "," pos "," s
    SetTimer, ShowTip_ChangeColor, Off
    Gui, ShowTip: Destroy
    if (s="")
        return
    ; WS_EX_NOACTIVATE:=0x08000000, WS_EX_TRANSPARENT:=0x20
    Gui, ShowTip: +LastFound +AlwaysOnTop +ToolWindow -Caption +E0x08000020
    Gui, ShowTip: Color, FFFFF0
    WinSet, TransColor, FFFFF0 150
    Gui, ShowTip: Margin, 10, 5
    Gui, ShowTip: Font, Q3 s20 bold
    Gui, ShowTip: Add, Text,, %s%
    Gui, ShowTip: Show, NA %pos%, ShowTip
    SetTimer, ShowTip_ChangeColor, 1000
    ShowTip_ChangeColor:
    Gui, ShowTip: +AlwaysOnTop
    r:=StrSplit(SubStr(bak,1,InStr(bak,",")-1),"|")
    Gui, ShowTip: Font, % "Q3 c" r[idx:=Mod(Round(idx),r.length())+1]
    GuiControl, ShowTip: Font, Static1
    return
}
;============ LOGANS CODE ===========================================================================================
; TODO maybe remove the need for AutoHotKey.exe
; WHAT IS THIS: #MaxThreadsPerHotkey, 2 ;with this each hotkey can have more than 1 "thread" allowing us to execute "space::" again
; _________________________________________________________________________
; Menu Code
MenuHandler_PrintmacroRunsRemaining:
    MsgBox, % "DEBUG - macroRunsRemaining: " . macroRunsRemaining
Return

MenuHandler_Send:
Messege = 
(
To bind the hotkey:

1. Open your keyboard and mouse software and get ready to bind a new key press.

2. Three seconds after your click 'Ok' the 'F24' key will be simulated.

3. If you time it correctly you can capture this simulated keypress and bind it to your keyboard or mouse.

Ready to level up!?
)
	Msgbox, 49, Bind the Hotkey, %Messege%
	IfMsgBox Cancel
		return	; Do nothing
	else
		ShowTip("Simulating Hotkey in 3")
		Sleep, 1000
		ShowTip("Simulating Hotkey in 2")
		Sleep, 1000
		ShowTip("Simulating Hotkey in 1")
		Sleep, 1000
		ShowTip("Sent")
		Send, {F24}
		Sleep, 1000
		ShowTip("")
return

MenuHandler_About:
;Answer := CMsgBox( title, text, buttons, icon="", owner=0 )
Messege = 
(
OneKey Instant Macro is a lightweight Macro Recorder.

To use:
1. Record a new macro by Holding the hotkey.
2. Playback the macro by short clicking the hotkey.
   It's that easy!

Bind the hotkey to your keyboard or mouse by 
 - Right click on the 'OneKey Instant Macro' process in your system tray 
 - Then select "Send Hotkey for Binding" option.
	
Written by Logan Krantz.

Acknowledgements
This utility was built using AutoHotKey.
The code in this utility was heavily reliant on that AutoHotKey script Macro Recorder v2.1 By FeiYue.
)
	Answer := CMsgBox("About OneKey Instant Macro", Messege, "Close About|Visit Website")
	if (Answer="Visit Website") {
		Run, https://github.com/LoganTraceur/OneKey
	}
return

; _________________________________________________________________________
; Manage Hot Key Presses
; Hotkey Pressed Down
*F24::      ; * Prefix wildcard. Fire the hotkey even if extra modifiers are being held down
	If isHotKeyPressed
		return
	wasHotKeyHeldDown := false					; reset value
	isHotKeyPressed := true
	SetTimer, waitForHotKeyRelease, 500			; milliseconds
return

; Hotkey Released
*F24 Up::
	isHotKeyPressed := false
	SetTimer, waitForHotKeyRelease, Off

	if (wasHotKeyHeldDown) {
		;Msgbox, End of Long Press: Stop Recording the Macro
		Goto, Stop
	} else {
		;Msgbox, End of Short Press: Play Macro
        macroRunsRemaining := macroRunsRemaining + 1    ; Increment the number of time the macro should run
        ;MsgBox, % "START - macroRunsRemaining: " . macroRunsRemaining
       ;if (macroRunsRemaining < 1) ; Do nothing as this shouldnt happen
       ;if (macroRunsRemaining > 1) ; Do nothing as this is controlled in "Goto, Play"
        if (macroRunsRemaining == 1) {
            Goto, Play ; Start the macro which will continue the loop if required
        }
	}
return



; Hotkey Held down
waitForHotKeyRelease:
	;MsgBox, You held down the hotkey key.
	SetTimer, waitForHotKeyRelease, Off			; Turn off timeer	
	wasHotKeyHeldDown := true					; Add flag
	;Msgbox, Start Recording
	Goto, recordScreenStart
return

;============ END ===========================================================================================
; _________________________________________________________________________
; Hotkey and named methods

; Command: RECORD Screen
;F1::
recordScreenStart:							; This is a GOTO Label
	Suspend, Permit
	Goto, RecordScreen
return ; ADDED BY LOGAN

; Command: RECORD Window
;F2
;	Suspend, Permit
;	Goto, RecordWindow
;return ; ADDED BY LOGAN

RecordScreen:								; This is a GOTO Label
    ;RecordWindow:							; This is a GOTO Label
    if (Recording or Playing)
        return
    Coord:=InStr(A_ThisLabel,"Win") ? "Window":"Screen"
    LogArr:=[], oldid:="", Log(), Recording := TRUE, SetHotkey(1)
    ShowTip("Recording")
return


; Command: STOP
;F3::
Stop:										; This is a GOTO Label
    Suspend, Permit
    if Recording {
        if (LogArr.MaxIndex()>0) {
            s:="`nLoop, 1`n{`n`nSetTitleMatchMode, 2"
                . "`nCoordMode, Mouse, " Coord "`n"
            For k,v in LogArr
                s.="`n" v "`n"
            s.="`nSleep, 50`n`n}`n"
            s:=RegExReplace(s,"\R","`n")
            FileDelete, %LogFile%
            FileAppend, %s%, %LogFile%
            s:=""
        }
        SetHotkey(0), Recording:= FALSE, LogArr:=""
    }
    else if Playing {
        WinGet, list, List, %Play_Title%
        Loop, % list
            if WinExist("ahk_id " list%A_Index%)!=A_ScriptHwnd
            {
                WinGet, pid, PID
                WinClose,,, 3
                IfWinExist
                    Process, Close, %pid%
            }         
            SetTimer, CheckPlay, Off
            Playing := FALSE
    }
    ShowTip()
    Suspend, Off
    Pause, Off
    GuiControl,, Pause, % "[F6] Pause "
    isPaused := FALSE
    ;ShowTip("Saved")
    ;SetTimer, ShowTip(""), 200			; milliseconds
return

; Command: PLAY
;F4::
Play:										; This is a GOTO Label
    Suspend, Permit
    if (Recording or Playing){
        Msgbox, "STOP TRIGGERED"
        Gosub, Stop
    }
    ahk:=A_IsCompiled ? A_ScriptDir "\AutoHotkey.exe" : A_AhkPath
    IfNotExist, %ahk%
    {
        MsgBox, 4096, Error, Can't Find %ahk% !
        Exit
    }
    if FileExist(LogFile) {
        Run, %ahk% /r "%LogFile%"
        SetTimer CheckPlay, 50
        Gosub, CheckPlay
    }else{
        ShowTip("Hold to RECORD a Macro and click to PLAY")
        ;SetTimer, ShowTip(), 2000			; milliseconds
    }
return

CheckPlay:										; This is a GOTO Label
    Check_OK := FALSE
    WinGet, list, List, %Play_Title%
    Loop, % list {
        if (list%A_Index%!=A_ScriptHwnd){
            Check_OK := TRUE
        }
    }       
    
    if (Check_OK == TRUE) {
        Playing := TRUE
        ShowTip("Playing (" macroRunsRemaining  ")")
    } else if (Playing == TRUE) {
        Playing := FALSE                                ; Reset Condition
        SetTimer, CheckPlay, Off                        ; Turn off the timer that called this method
        macroRunsRemaining := macroRunsRemaining - 1    ; Macro Finished, Reduce Counter
        ShowTip()                                       ; Clear Tip
        if (macroRunsRemaining > 0) {
            Goto, Play        
        }
    } 
return

; Command: EDIT
;F5::
Edit:										; This is a GOTO Label
    Suspend, Permit
    Gosub, Stop
    if FileExist(LogFile){
        Run, notepad.exe "%LogFile%"
    } else {
        Msgbox, No Macro has been recorded. Hold the hotkey to RECORD a Macro and click to PLAY
    }
return


; Command: PAUSE
;F6::
Pause:										; This is a GOTO Label
    Suspend, Permit
    if Recording
    {
        Suspend
        Pause, % A_IsSuspended ? "On":"Off", 1
        isPaused:=A_IsSuspended, Log()
    }
    else if Playing
    {
        isPaused:=!isPaused
        WinGet, list, List, %Play_Title%
        Loop, %list%
            if WinExist("ahk_id " list%A_Index%)!=A_ScriptHwnd
                PostMessage, 0x111, 65306
    }
    else return
    if isPaused
        GuiControl,, Pause, [F6]<Pause>
    else
        GuiControl,, Pause, % "[F6] Pause "
return


SetHotkey(f:=0) {
    ; These keys are already used as hotkeys
    global UsedKeys
    f:=f ? "On":"Off"
    Loop, 254  {
        k:=GetKeyName(vk:=Format("vk{:X}", A_Index))
        if k not in ,Control,Alt,Shift,%UsedKeys%
            Hotkey, ~*%vk%, LogKey, %f% UseErrorLevel
    }
    For i,k in StrSplit("NumpadEnter|Home|End|PgUp"
        . "|PgDn|Left|Right|Up|Down|Delete|Insert", "|")
    {
        sc:=Format("sc{:03X}", GetKeySC(k))
        if k not in ,Control,Alt,Shift,%UsedKeys%
            Hotkey, ~*%sc%, LogKey, %f% UseErrorLevel
    }
    SetTimer, LogWindow, %f%
    if (f="On")
        Gosub, LogWindow
}

; _________________________________________________________________________
; Log Recordings
LogKey:
    LogKey()
return

LogKey() {
    Critical
    k:=GetKeyName(vksc:=SubStr(A_ThisHotkey,3))
    k:=StrReplace(k,"Control","Ctrl"), r:=SubStr(k,2)
    if r in Alt,Ctrl,Shift,Win
    LogKey_Control(k)
    else if k in LButton,RButton,MButton
    LogKey_Mouse(k)
    else
    {
    if (k="NumpadLeft" or k="NumpadRight") and !GetKeyState(k,"P")
      return
    k:=StrLen(k)>1 ? "{" k "}" : k~="\w" ? k : "{" vksc "}"
    Log(k,1)
    }
}

LogKey_Control(key) {
    global LogArr, Coord
    k:=InStr(key,"Win") ? key : SubStr(key,2)
    if (k="Ctrl") {
        CoordMode, Mouse, %Coord%
        MouseGetPos, X, Y
    }
    Log("{" k " Down}",1)
    Critical, Off
    KeyWait, %key%
    Critical
    Log("{" k " Up}",1)
    if (k="Ctrl") {
        i:=LogArr.MaxIndex(), r:=LogArr[i]
        if InStr(r,"{Blind}{Ctrl Down}{Ctrl Up}")
          LogArr[i]:="MouseMove, " X ", " Y
    }
}

LogKey_Mouse(key) {
    global gui_id, LogArr, Coord
    k:=SubStr(key,1,1)
    CoordMode, Mouse, %Coord%
    MouseGetPos, X, Y, id
    if (id=gui_id)
            return
        Log("MouseClick, " k ", " X ", " Y ",,, D")
        CoordMode, Mouse, Screen
        MouseGetPos, X1, Y1
        t1:=A_TickCount
        Critical, Off
        KeyWait, %key%
        Critical
        t2:=A_TickCount
        if (t2-t1<=200)
        X2:=X1, Y2:=Y1
    else
        MouseGetPos, X2, Y2
        i:=LogArr.MaxIndex(), r:=LogArr[i]
        if InStr(r, ",,, D") and Abs(X2-X1)+Abs(Y2-Y1)<5
        LogArr[i]:=SubStr(r,1,-5), Log()
    else
        Log("MouseClick, " k ", " (X+X2-X1) ", " (Y+Y2-Y1) ",,, U")
}

LogWindow:
    LogWindow()
return

LogWindow() {
    global oldid, LogArr
    static oldtitle
    id:=WinExist("A")
    WinGetTitle, title
    WinGetClass, class
    if (title="" and class="")
        return  
    if (id=oldid and title=oldtitle)
        return
    oldid:=id, oldtitle:=title
    title:=SubStr(title,1,50)
    if (!A_IsUnicode)
    {
        GuiControl,, MyText, %title%
        GuiControlGet, s,, MyText
        if (s!=title)
          title:=SubStr(title,1,-1)
    }
    title.=class ? " ahk_class " class : ""
    title:=RegExReplace(Trim(title), "[``%;]", "``$0")
    s:="tt = " title "`nWinWait, %tt%"
        . "`nIfWinNotActive, %tt%,, WinActivate, %tt%"
    i:=LogArr.MaxIndex(), r:=LogArr[i]
    if InStr(r,"tt = ")=1
        LogArr[i]:=s, Log()
    else
        Log(s)
}

Log(str:="", Keyboard:=0) {
    global LogArr
    static LastTime
    t:=A_TickCount, Delay:=(LastTime ? t-LastTime:0), LastTime:=t
    IfEqual, str,, return
    i:=LogArr.MaxIndex(), r:=LogArr[i]
    if (Keyboard and InStr(r,"Send,") and Delay<1000)
    {
        LogArr[i]:=r . str
        return
    }
    if (Delay>200){
        ;LOG SLEEP COMMANDS 
        LogArr.Push("Sleep, " 50)                ; Sleep = 50ms
        ;LogArr.Push("Sleep, " (Delay//2))       ; Sleep = half delay
        ;LogArr.Push("Sleep, " Delay)            ; Sleep = real time delay        
    }
    LogArr.Push(Keyboard ? "Send, {Blind}" str : str)
}

;============ The End Of Logging ============

; ================================================================================================================================================
; CUSTOM MESSAGE BOX
CMsgBox( title, text, buttons, icon="", owner=0 ) {
    Global _CMsg_Result

    GuiID := 9      ; If you change, also change the subroutines below

    StringSplit Button, buttons, |

    If( owner <> 0 ) {
        Gui %owner%:+Disabled
        Gui %GuiID%:+Owner%owner%
    }

    Gui %GuiID%:+Toolwindow +AlwaysOnTop

    MyIcon := ( icon = "I" ) or ( icon = "" ) ? 222 : icon = "Q" ? 24 : icon = "E" ? 110 : icon

    Gui %GuiID%:Add, Picture, Icon%MyIcon% , Shell32.dll
    Gui %GuiID%:Add, Text, x+12 yp w350 r17 section , %text%

    Loop %Button0% 
        Gui %GuiID%:Add, Button, % ( A_Index=1 ? "x+12 ys " : "xp y+3 " ) . ( InStr( Button%A_Index%, "*" ) ? "Default " : " " ) . "w100 gCMsgButton", % RegExReplace( Button%A_Index%, "\*" )

    Gui %GuiID%:Show,,%title%
  
    Loop 
        If( _CMsg_Result )
            Break

    If( owner <> 0 )
        Gui %owner%:-Disabled
    
    Gui %GuiID%:Destroy
    Result := _CMsg_Result
    _CMsg_Result := ""
    Return Result
}

9GuiEscape:
9GuiClose:
    _CMsg_Result := "Close"
Return

CMsgButton:
    StringReplace _CMsg_Result, A_GuiControl, &,, All
Return