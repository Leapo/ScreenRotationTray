;==============================================================================================
; Set Defaults
;==============================================================================================
#Persistent
#SingleInstance force
#NoEnv
SendMode Input

EnableAnim_Static = 1
ModernPmpt_Static = 1

WaitToEvaluate = 0
ResDir = %A_ScriptDir%\Data

;==============================================================================================
; String Table
;==============================================================================================
Str_TM0 := "Screen Rotation"				;Traytip and Window Title
Str_TM1 := "Screen Rotation Options:"		;Menu Handler
Str_TM2 := "Landscape	0"
Str_TM3 := "Inverted Landscape	180"
Str_TM4 := "Portrait	90"
Str_TM5 := "Inverted Portrait	270"
Str_TM6 := "Exit"
Str_TM7 := "Modern Prompt"
Str_TM8 := "Enable Animations"

;==============================================================================================
; Config File
;==============================================================================================
IfNotExist, %A_ScriptDir%\Config.ini		; Write config if one doesn't already exist
	GoSub, NewConfig

IniRead, ModernPmpt, %A_ScriptDir%\Config.ini, TModeToggle, ModernPmpt
IniRead, EnableAnim, %A_ScriptDir%\Config.ini, TModeToggle, EnableAnim

BadCfg = 0
If (ModernPmpt != 1) and (ModernPmpt != 0)
	BadCfg = 1
If (EnableAnim != 1) and (EnableAnim != 0)
	BadCfg = 1

If (BadCfg = 1)
{
	ModernPmpt = %ModernPmpt_Static%
	EnableAnim = %EnableAnim_Static%
	GoSub, NewConfig
}

;==============================================================================================
; Build tray icon and right-click menu
;==============================================================================================
Menu, Tray, Icon, %ResDir%\Icon.ico, , 1	;Tray Icon
Menu, Tray, Tip, %Str_TM0%					;Set Traytip
Menu, Tray, NoStandard						;Remove standard items
GoSub, TM_SegR								;Build initial right-click menu

;==============================================================================================
; Hotkeys
;==============================================================================================
#IfWinExist, Screen Rotation					;Clicking outside of the prompt closes it
	~LButton::
		IfWinNotActive, Screen Rotation
			GoSub, GuiSlideOut
	return

;==============================================================================================
;##################################  END AUTO-EXECUTE BLOCK  ##################################
;==============================================================================================
Return

;==============================================================================================
; Function - Config File Handlers
;==============================================================================================
NewConfig:
	FileDelete, %A_ScriptDir%\Config.ini
	IniWrite, %ModernPmpt_Static%, %A_ScriptDir%\Config.ini, TModeToggle, ModernPmpt
	IniWrite, %EnableAnim_Static%, %A_ScriptDir%\Config.ini, TModeToggle, EnableAnim
	BadCfg = 0
Return

UpdateConfig:
	IniWrite, %ModernPmpt%, %A_ScriptDir%\Config.ini, TModeToggle, ModernPmpt
	IniWrite, %EnableAnim%, %A_ScriptDir%\Config.ini, TModeToggle, EnableAnim
Return

;==============================================================================================
; Menu - Tray Menu Segments
;==============================================================================================
TM_SegR:
	Menu, Tray, Add, %Str_TM1%, TM_Act1		;Menu handler menu item
	Menu, Tray, Add
	GoSub, TM_SegL							;Insert left-click menu items
	Menu, Tray, Add
	Menu, Tray, Add, %Str_TM7%, TM_Act7		;Modern Prompt
	Menu, Tray, Add, %Str_TM8%, TM_Act8		;Enable Animations
	Menu, Tray, Add
	Menu, Tray, Add, %Str_TM6%, TM_Act6		;Exit menu item
	Menu, Tray, Disable, %Str_TM1%			;Gray-out the menu handler
	Menu, Tray, Default, %Str_TM1%			;Set default trayclick action to menu handler
	Menu, Tray, Click, 1					;Single-click to activate
	
	If (ModernPmpt = 0)
	{
		Menu, Tray, Uncheck, %Str_TM7%
		Menu, Tray, Disable, %Str_TM8%
	}
	Else
	{
		Menu, Tray, Check, %Str_TM7%
		Menu, Tray, Enable, %Str_TM8%
	}
	
	If (EnableAnim = 0)
		Menu, Tray, Uncheck, %Str_TM8%
	Else
		Menu, Tray, Check, %Str_TM8%
Return

TM_SegL:
	Menu, Tray, Add, %Str_TM2%, TM_Act2		;Landscape
	Menu, Tray, Add, %Str_TM3%, TM_Act3		;Inverted Landscape
	Menu, Tray, Add, %Str_TM4%, TM_Act4		;Portrait
	Menu, Tray, Add, %Str_TM5%, TM_Act5		;Inverted Portrait
	Menu, Tray, Icon, %Str_TM2%, %ResDir%\Icon_L.ico
	Menu, Tray, Icon, %Str_TM3%, %ResDir%\Icon_IL.ico
	Menu, Tray, Icon, %Str_TM4%, %ResDir%\Icon_P.ico
	Menu, Tray, Icon, %Str_TM5%, %ResDir%\Icon_IP.ico
Return

;==============================================================================================
; Menu - Tray Menu Actions
;==============================================================================================
TM_Act1:									;Tablet Mode Prompt	
	If (WaitToEvaluate = 1)					;Prevents GUI collissions
		Return
	Else
		GoSub, TM_Act1_Sub1
Return

TM_Act1_Sub1:								;Open tray menu on left or right click
	WaitToEvaluate = 1
	If (ModernPmpt = 1)
	{
		IfWinNotExist, Screen Rotation
			GoSub, RotationPrompt
		Else
			GoSub, GuiSlideOut
	}
	Else
	{
		Menu, Tray, DeleteAll				;Clear tray menu and render left-click menu
		GoSub, TM_SegL
		MouseClick, Right
		Menu, Tray, DeleteAll				;Clear tray menu and render right-click menu
		GoSub, TM_SegR
	}
	WaitToEvaluate = 0
Return

TM_Act2:									;Landscape
	Send, ^!{Up}
Return

TM_Act3:									;Inverted Landscape
	Send, ^!{Down}
Return

TM_Act4:									;Portrait
	Send, ^!{Left}
Return

TM_Act5:									;Inverted Portrait
	Send, ^!{Right}
Return

TM_Act6:									;Exit App
	ExitApp
Return

TM_Act7:									;Use modern prompt
	If (ModernPmpt = 1)
		ModernPmpt = 0
	Else
		ModernPmpt = 1

	Menu, Tray, DeleteAll
	GoSub, TM_SegR
	GoSub, UpdateConfig
Return

TM_Act8:									;Enable Animations
	If (EnableAnim = 1)
		EnableAnim = 0
	Else
		EnableAnim = 1
	
	Menu, Tray, DeleteAll
	GoSub, TM_SegR
	GoSub, UpdateConfig
Return

;==============================================================================================
; GUI - Button Actions
;==============================================================================================
Link1:
	GoSub, GuiSlideOut
	Run, ms-settings:screenrotation
Return

Button1_down:
	Sleep 125
	GoSub, TM_Act2
	GoSub, GuiSlideOut
return

Button2_down:
	Sleep 125
	GoSub, TM_Act3
	GoSub, GuiSlideOut
Return

Button3_down:
	Sleep 125
	GoSub, TM_Act4
	GoSub, GuiSlideOut
Return

Button4_down:
	Sleep 125
	GoSub, TM_Act5
	GoSub, GuiSlideOut
Return

Button1_down_up:
return
Button2_down_up:
return
Button3_down_up:
return
Button4_down_up:
return

;==============================================================================================
; GUI - Main Window
;==============================================================================================
RotationPrompt:
	;Set Initial variables for GUI height and width
	WinH = 112
	WinW = 361
	
	;Calculate internal variables based on height and width
	WinX := A_ScreenWidth-WinW
	
	WinGetPos, , , , TrayHeightInt, ahk_class Shell_TrayWnd
	If (TrayHeightInt != "")
		TrayHeight = %TrayHeightInt%
	If ((TrayHeightInt = "") and (TrayHeight = ""))
		TrayHeight = 40
	If (EnableAnim = 1)
		WinY := A_ScreenHeight-TrayHeight-53
	Else
		WinY := A_ScreenHeight-WinH-TrayHeight
		
	WinH2 := WinH-1
	WinW2 := WinW-1
	WinX2 := WinX+1
	WinY2 := WinY+1
	
	;Frame GUI
	Gui 1:-Caption -SysMenu +Owner +ToolWindow +Disabled
	Gui 1:Color, 9F9F9F
	
	;Background GUI
	Gui 2:-Caption -SysMenu +Owner +ToolWindow
	Gui 2:Color, 404040
	
	;Static Images
	Gui 2:Add, Pic, x4 y47, %ResDir%\Bttn_L_Hvr.png
	Gui 2:Add, Pic, x93 y47, %ResDir%\Bttn_IL_Hvr.png
	Gui 2:Add, Pic, x182 y47, %ResDir%\Bttn_P_Hvr.png
	Gui 2:Add, Pic, x271 y47, %ResDir%\Bttn_IP_Hvr.png
	
	;Image Buttons
	AddGraphicButton(2, "x4", "y47", "h60", "w85", "button1", resdir . "\Bttn_L_Up.png", resdir . "\Bttn_L_Hvr.png", resdir . "\Bttn_L_Dwn.png")
	AddGraphicButton(2, "x93", "y47", "h60", "w85", "button2", resdir . "\Bttn_IL_Up.png", resdir . "\Bttn_IL_Hvr.png", resdir . "\Bttn_IL_Dwn.png")
	AddGraphicButton(2, "x182", "y47", "h60", "w85", "button3", resdir . "\Bttn_P_Up.png", resdir . "\Bttn_P_Hvr.png", resdir . "\Bttn_P_Dwn.png")
	AddGraphicButton(2, "x271", "y47", "h60", "w85", "button4", resdir . "\Bttn_IP_Up.png", resdir . "\Bttn_IP_Hvr.png", resdir . "\Bttn_IP_Dwn.png")
	
	;Display Properties Link
	Gui 2:Font, C1e91ea S13, Calibri
	Gui 2:Add, Text, x13 y12 w347 h20 gLink1 vDPLink, %Str_TM0%
	
	;Show GUI
	Gui 1:Show, x%WinX% y%WinY% h%WinH% w%WinW%, %Str_TM0% FR
	WinSet, Transparent, 72, %Str_TM0% FR
	
	Gui 2:Show, x%WinX2% y%WinY2% h%WinH2% w%WinW2%, %Str_TM0% BG
	WinSet, Transparent, 236, %Str_TM0% BG

	;Animate
	If (EnableAnim = 1)
		GoSub, GuiSlideIn

	Gui 1:+AlwaysOnTop
	Gui 2:+AlwaysOnTop
	
	;Enable bitmap buttons and hover cursor
	global CurrentCursor := 0
	OnMessage(0x20,  "WM_SETCURSOR")
	OnMessage(0x200, "MouseMove")
	OnMessage(0x201, "MouseLDown")
	OnMessage(0x202, "MouseLUp")
Return

;==============================================================================================
; GUI - Animations
;==============================================================================================
GuiSlideIn:
	If (EnableAnim = 1)
	{
		SetWinDelay, 10
			Loop, 1
			{
				WinY := WinY-40
				WinY2 := WinY2-40
				WinMove, %Str_TM0% FR, , , WinY
				WinMove, %Str_TM0% BG, , , WinY2
			}
			Loop, 1
			{
				WinY := WinY-8
				WinY2 := WinY2-8
				WinMove, %Str_TM0% FR, , , WinY
				WinMove, %Str_TM0% BG, , , WinY2
			}
			Loop, 2
			{
				WinY := WinY-4
				WinY2 := WinY2-4
				WinMove, %Str_TM0% FR, , , WinY
				WinMove, %Str_TM0% BG, , , WinY2
			}
			Loop, 3
			{
				WinY := WinY-1
				WinY2 := WinY2-1
				WinMove, %Str_TM0% FR, , , WinY
				WinMove, %Str_TM0% BG, , , WinY2
			}
		SetWinDelay, 100
	}
Return

GuiSlideOut:
	If (EnableAnim = 1)
	{		
		Gui 1:-AlwaysOnTop
		Gui 2:-AlwaysOnTop
		
		SetWinDelay, 10
			;Loop, 2
			;{
				WinY := WinY+48
				WinY2 := WinY2+48
				WinMove, %Str_TM0% FR, , , WinY
				WinMove, %Str_TM0% BG, , , WinY2
				WinMove, %Str_TM0%, , , WinY2
			;}
		SetWinDelay, 100
	}
	Else
	{
		Sleep, 150
	}
	Gui 1:Destroy
	Gui 2:Destroy
Return

;==============================================================================================
; Function - Bitmap Buttons
;==============================================================================================
WM_SETCURSOR(wParam, lParam)
{	
	Global DPLinkColor						;Make this a global variable (prevents flickering)
	
	HitTest := lParam & 0xFFFF
	if (HitTest = 1 && CurrentCursor != 0)
	{
		DPLinkColor = 1						;Highlight text
		Gui 2:Font, cB4B4B4
		GuiControl, 2:Font, DPLink
											;Set cursor to hand
		DllCall("SetCursor", "ptr", CurrentCursor)
		return true							;Do not do further cursor processing (ie: skip default behavior)
	}
	Else
	{
		If (DPLinkColor = 1)				;Return text color to normal
		{
			DPLinkColor = 0
			Gui 2:Font, c1E91EA
			GuiControl, 2:Font, DPLink
		}
	}
}


MouseMove(wParam, lParam, msg, hwnd)
{
   Global
   local Current_Hover_Image
   local Current_Main_Image
   local Current_GUI
   loop, parse, Graphic_Button_List, |
   {
      Current_GUI := %a_loopField%_GUI_Number
      If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData1 != %a_loopField%_HWND)
      {
		 Current_Hover_Image := %a_loopField%_Hover_Image
         GuiControl, -Redraw, %a_loopField%		;Disable redraw to help prevent GUI flicker
		 guicontrol, %Current_GUI%:, %a_loopField%, %Current_Hover_Image%
		 GuiControl, +Redraw, %a_loopField%		;Re-Enable redraw
         %a_loopField%LastButtonData1 := hwnd
      }
      else if(hwnd != %a_loopField%_HWND) and (%a_loopField%LastButtonData1 = %a_loopField%_HWND)
      {
		 Current_Up_Image := %a_loopField%_Up_Image
         GuiControl, -Redraw, %a_loopField%		;Disable redraw to help prevent GUI flicker
		 guicontrol, %Current_GUI%:, %a_loopField%, %Current_Up_Image%
		 GuiControl, +Redraw, %a_loopField%		;Re-Enable redraw
         %a_loopField%LastButtonData1 := hwnd
         %a_loopField%LastButtonData2 =
       tooltip,
      }
   }

   ;Quick hack to add a hover cursor in addition to bitmap buttons
	static Hand := DllCall("LoadCursor", "ptr", 0, "ptr", 32649)
	if A_GuiControl in DPLink
		CurrentCursor := Hand
	else
		CurrentCursor := 0

	Return
}


MouseLDown(wParam, lParam, msg, hwnd)
{
   Global
   Local Current_Down_Image
   Local Current_GUI
   loop, parse, Graphic_Button_List, |
   {
      If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData2 != %a_loopField%_HWND)
      {
         Current_GUI := %a_loopField%_GUI_Number
         Current_Down_Image := %a_loopField%_Down_Image
         guicontrol, %Current_GUI%:, %a_loopField%, %Current_Down_Image%
         %a_loopField%LastButtonData2 := hwnd
         break
      }
   }
   Return
}


MouseLUp(wParam, lParam, msg, hwnd)
{
   Global
   local Current_Main_Image
   Local Current_GUI
   loop, parse, Graphic_Button_List, |
   {
      If (hwnd = %a_loopField%_HWND) and (%a_loopField%LastButtonData2 = %a_loopField%_HWND)
      {
         Current_GUI := %a_loopField%_GUI_Number
         Current_Hover_Image := %a_loopField%_Hover_Image
         guicontrol, %Current_GUI%:, %a_loopField%, %Current_Hover_Image%
         %a_loopField%LastButtonData2 =
         GOSUB % a_loopField . "_Down_Up"
         break
      }
   }
   Return
}


AddGraphicButton(GUI_Number, Button_X, Button_Y, Button_H, Button_W, Button_Identifier, Button_Up, Button_Hover, Button_Down)
{
   Global
   if(Graphic_Button_List = "")
      Graphic_Button_List .= Button_Identifier
   else
      Graphic_Button_List .= "|" . Button_Identifier
   current_Button_HWND := Button_Identifier . "_hwnd"
   %Button_Identifier%_Up_Image := Button_Up
   %Button_Identifier%_Hover_Image := Button_Hover
   %Button_Identifier%_Down_Image := Button_Down
   %Button_Identifier%_GUI_Number := GUI_Number   
   Gui, %GUI_Number%:Add, Picture, +altsubmit %Button_X% %Button_Y% %Button_H% %Button_W% g%Button_Identifier%_Down v%Button_Identifier% hwnd%current_Button_HWND%, %Button_Up%
}