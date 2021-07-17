/*
 *********************************************************************************
 * 
 * clipboardresize.ahk
 * 
 * use UTF-8 BOM codec
 * 
 * Version :  appVersion
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 *
 *
 *********************************************************************************
*/
/*
 *********************************************************************************
 * 
 * MIT License
 * 
 * 
 * Copyright (c) 2020 jvr.de. All rights reserved.
 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of
 * this software and associated documentation files (the "Software"), to deal in
 * the Software without restriction, including without limitation the rights to
 * use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
 * of the Software, and to permit persons to whom the Software is furnished to do
 * so, subject to the following conditions:

 * The above copyright notice and this permission notice shall be included in all 
 * copies or substantial portions of the Software.

 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
 * UTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN 
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
  *********************************************************************************
*/

; Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11
; Modifed by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
; Supports: Basic, _L ANSi, _L Unicode x86 and _L Unicode x64
; Modifed by jvr


#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn  ; Enable warnings to assist with detecting common errors.
#SingleInstance Force
#Persistent

#Include, Lib\Gdip_All_patched.ahk
#Include, Lib\ahk_common.ahk

tipOffsetDeltaX := 0
startDelayAfterClipboardChange := 100
automodeVari := false

msgDefault := ""

MainStatusBarHwnd := 0

gdiToken := 0

activeWin := 0

SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

wrkDir := A_ScriptDir . "\"
saveDir := wrkDir . "_savedclips\"

appName := "ClipboardResize"
appVersion := "0.131"
app := appName . " " . appVersion
iniFile := A_ScriptDir . "\clipboardresize.ini"

posXsave := 0
posYsave := 0

MouseGetPos, posXsave, posYsave

guiWidthDefault := 590
guiWidth := guiWidthDefault

guiHeightDefault := 500
guiHeight := guiHeightDefault

internalPreviewWidthDefault := 560
internalPreviewWidth := internalPreviewWidthDefault

internalPreviewHeightDefault := 390
internalPreviewHeight := internalPreviewHeightDefault 
	
fontDefault := "Calibri"
font := fontDefault

fontsizeDefault := 10
fontsize := fontsizeDefault

holdtimeDefault := 3000 ; milliseconds
holdtime := holdtimeDefault

holdtimeshortDefault := 2000 ; milliseconds
holdtimeshort := holdtimeshortDefault

holdtimelongDefault := 6000 ; milliseconds (currently not used)
holdtimelong := holdtimelongDefault

filemanagerDefault := ""
filemanager := filemanagerDefault


menuHotkeyDefault := "+#z"
menuHotkey := menuHotkeyDefault

exitHotkeyDefault := "+!#z"
exitHotkey := exitHotkeyDefault

captureAndResizeHotkeyDefault := "#z"
captureAndResizeHotkey := captureAndResizeHotkeyDefault

captureAndResizeSaveHotkeyDefault := "^#z"
captureAndResizeSaveHotkey := captureAndResizeSaveHotkeyDefault

setsizeValuesHotkeyDefault := "!#z"
setsizeValuesHotkey := setsizeValuesHotkeyDefault

ocrHotkeyDefault := "#y"
ocrHotkey := ocrHotkeyDefault

targetWidth := 800
targetHeight := 600

clipboardBeepSound := ""

msg_control_string = If checked:`nAn automatic resize operation is executed`nif a new clipboard-image is detected!,automodeVari

readIni()

OnClipboardChange("OnClipboardChangeFunction",1)

hideOnStartup := true

Loop % A_Args.Length()
{
	if(eq(A_Args[A_index],"remove"))
		exit()
	
	if(eq(A_Args[A_index],"hidewindow")){
		hideOnStartup := true
	}
	
	if(eq(A_Args[A_index],"showwindow")){
		hideOnStartup := false
	}
}

if (hideOnStartup){
	tipTopTime(app . " started, hotkey is: " . hotkeyToText(menuHotkey), 4000)
	mainWindow(true)
} else {
	mainWindow()
}


return

;-------------------------------- mainWindow --------------------------------
mainWindow(hide := false) {
	global app
	global appName
	global font
	global fontsize
	global targetWidth
	global targetHeight
	global menuHotkey
	global exitHotkey

	global captureAndResizeHotkey
	global captureAndResizeSaveHotkey
	global setsizeValuesHotkey
	
	global guiWidth
	global guiHeight
	global internalPreviewWidth
	global internalPreviewHeight
	global MainStatusBarHwnd
	global automodeVari
	global resizeVari
	global appVersion
	global InternalPreviewImage
	global msgDefault
	
	Gui, guiMain:destroy
		
	; Move to menuposition
	CoordMode,Mouse,Screen
	WinGetPos, winTopL_x, winTopL_y, width, height, A
	winCenter_x := winTopL_x + width/2
	;winCenter_y := winTopL_y + height/2
	;MouseMove, winCenter_x - 500, 100, 0
	DllCall("SetCursorPos", int, winCenter_x - 500, int, 100)

	showFullSizeViewText := "FullSizeView clipboard image"
	setsizeValuesText := "Set target-size (is: " . targetwidth " x " . targetheight . "): " . hotkeyToText(setsizeValuesHotkey)
	
	Menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.
	Menu, MainMenu, NoDefault
	Menu, MainMenu, DeleteAll
	
	Menu, MainMenu, Add,%showFullSizeViewText%, showFullSizeView
	Menu, MainMenu, Add,Update-check,checkUpdate

	Menu, MainMenu, Add,%setsizeValuesText%, setsizeValues
	
	captureAndResizeText := "Capture, resize: " . hotkeyToText(captureAndResizeHotkey)

	captureAndResizeSaveText := "Capture`, resize, save: " . hotkeyToText(captureAndResizeSaveHotkey)
	
	menuHotkeyText := "Hotkey: " . hotkeyToText(menuHotkey)

	exitHotkeyText := "Exit app: " . hotkeyToText(exitHotkey) 
	
	deltaY := fontsize * 2 + 4
	
	posiX1 := 75
	posiX2 := 210
	posiX3 := 250
	posiX4 := guiWidth - 100
	
	Gui, guiMain:New,+E0x08000000 +OwnDialogs +LastFound MaximizeBox HwndhMain, %app% %menuHotkeyText%

	Gui, guiMain:Font, s%fontsize%, %font%

	Gui, guiMain:Add, StatusBar, hwndMainStatusBarHwnd -Theme +BackgroundSilver
	
	Gui, guiMain:Add, Button, x5 y3 Default gresize VresizeVari,Resize
	
	Gui, guiMain:Add, Button, x%posiX1% yp+0 gresizeSave,Resize and save
	
	Gui, guiMain:Add, Button, x%posiX3% yp+0 gcaptureAndResizeStart, %captureAndResizeText%
	
	chk := automodeVari ? "checked" : ""
	Gui, guiMain:Add, CheckBox, x%posiX4% yp+0 VautomodeVari gsaveAutomode %chk%, Automode
	
	Gui, guiMain:Add, Button, x5 yp+%deltaY% gsaveOnly,Save only
	
	Gui, guiMain:Add, Button, x%posiX1% yp+0 gopenFilemanager vFilemanager,Filemanager (in "_savedclips")
	
	Gui, guiMain:Add, Button, x%posiX3% yp+0 gcaptureAndResizeSaveStart, %captureAndResizeSaveText%
	
	Gui, guiMain:Add, Button, x5 yp+%deltaY% gopenGithubPage, Open Github app-page
	
	Gui, guiMain:Add, Button, x%posiX3% yp+0 gexit,%exitHotkeyText%
	
	
	startGDI()
	pCRBitmap := Gdip_CreateBitmapFromClipboard()
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)

	if (Width > 0 && Height > 0) {
		resizeFactor := Min(internalPreviewWidth/Width, internalPreviewHeight/Height)
		newWidth :=  Round(Width*resizeFactor)
		newHeight := Round(Height*resizeFactor)
		
		PBitmapResized := Gdip_CreateBitmap(newWidth, newHeight)
		G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_DrawImage(G, pCRBitmap, 0, 0, newWidth, newHeight, 0, 0, Width, Height)
		
		hCRBitmap := Gdip_CreateHBITMAPFromBitmap(PBitmapResized)
		
		Gui, guiMain:Add, Pic, x5 yp+%deltaY% w%newWidth% h%newHeight% vInternalPreviewImage gClickImage,% "HBITMAP:*" hCRBitmap
	
		DeleteObject(hCRBitmap)
		
		msg := "Captured-image size: " . width . " x " . height . " , resize to: " . targetwidth "  x  " . targetheight 
		msgDefault := msg
		showMessage("", msg)
	} else {
		msg := "No image in clipboard!"
		msgDefault := msg
		showMessage("", msg)
		
		Gui, guiMain:Add, Pic, x5 yp+%deltaY% w%internalPreviewWidth% h%internalPreviewHeight% vInternalPreviewImage gClickImage, noImage.png
	}

	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
		
	Gui, guiMain:Menu, MainMenu
	
	setTimer,registerWindow,-500
	setTimer,checkFocus,3000
	Gui, guiMain:Show, w%guiWidth% h%guiHeight%
	
	OnMessage(0x200, "WM_MOUSEMOVE")
	OnMessage(0x2a3, "WM_MOUSELEAVE")
	
	if (hide){
		setTimer,checkFocus,delete
		Gui,guiMain:Hide
	}
	
	return
}
;-------------------------------- checkUpdate --------------------------------
checkUpdate(){
	if (!checkVersionFromGithub()){
		showErrorMessage("No new version available!")
	}
	
	return
}
;----------------------------- showErrorMessage -----------------------------
showErrorMessage(msg){

	showMessage("", msg)
	
	return
}
;------------------------------- WM_MOUSEMOVE -------------------------------
WM_MOUSEMOVE(wParam, lParam) {
	global msg_control_string
	
	;Gui, guiMain:submit, nohide

	X := lParam & 0xFFFF
	Y := lParam >> 16
	
	if (A_GuiControl){
		Loop, parse, msg_control_string, `,
		{ 
			if (A_GuiControl == A_LoopField){
				tooltip, %msg%,,,9
				break
			}
			msg := A_LoopField
		}
		sleep 10000
		OnMessage(0x200, "")
	ToolTip,,,,9
	}
	
	return
}      
;------------------------------- WM_MOUSELEAVE -------------------------------
WM_MOUSELEAVE(wParam, lParam) {
  OnMessage(0x200, "WM_MOUSEMOVE")
  ToolTip,,,,9
  
  return
}
;------------------------- OnClipboardChangeFunction -------------------------
OnClipboardChangeFunction(type){
	global startDelayAfterClipboardChange
	global automodeVari
	global holdtimelong
	global clipboardBeepSound
	
	OnClipboardChange("OnClipboardChangeFunction",0)
	
	setTimer,checkFocus,delete
	
	if (type == 1){
		;other than a captured image
		if (getkeystate("Capslock","T") != 1){
			clipboard := clipboard
			if (clipboardBeepSound != ""){
				f := cvtPath(clipboardBeepSound)
				SoundPlay, %f%
			}
		}
	}
	
	if (type == 2){
		sleep, startDelayAfterClipboardChange

		if (automodeVari){
			sleep, 1000
			resize()
			showWindowRefreshed()
		} else {
			showWindowRefreshed()
		}
	}
		
	OnClipboardChange("OnClipboardChangeFunction",1)
	
	return
}

;********************************* startGDI *********************************
startGDI(){
	global gdiToken

	if (gdiToken != 0){
		tipTopTime("Gdi already running!")
	} else {
		gdiToken := Gdip_Startup(1)
		
		If (gdiToken == 0) {
			MsgBox, 48, gdiplus error!, Gdiplus failed to start. File "Gdip_All_patched.ahk" missing? Please ensure you have gdiplus on your system
			exit()
		}
	}
	
	return
}
;********************************** stopGDI **********************************
stopGDI(){
	global gdiToken
	
	DllCall("CloseClipboard")
	Gdip_Shutdown(gdiToken)
	gdiToken := 0
	
	return
}
; *********************************** readIni *******************************
readIni(){
	global iniFile
	global targetWidth
	global targetHeight
	global menuHotkeyDefault
	global menuHotkey
	global exitHotkeyDefault
	global exitHotkey
	global resizeOnlyHotkeyDefault
	global resizeOnlyHotkey
	global captureAndResizeHotkeyDefault
	global captureAndResizeHotkey
	global captureAndResizeSaveHotkeyDefault
	global captureAndResizeSaveHotkey
	global ocrHotkeyDefault
	global ocrHotkey
	global setsizeValuesHotkeyDefault
	global setsizeValuesHotkey
	global holdtimeDefault
	global holdtime
	global holdtimeshortDefault
	global holdtimeshort
	global holdtimelongDefault
	global holdtimelong
	global filemanagerDefault
	global filemanager
	global fontDefault
	global font
	global fontsizeDefault
	global fontsize
	global guiWidth
	global guiWidthDefault
	global guiHeight
	global guiHeightDefault
	global internalPreviewWidth
	global internalPreviewWidthDefault
	global internalPreviewHeight
	global internalPreviewHeightDefault
	global automodeVari
	global clipboardBeepSound
	
	IniRead, guiWidth, %iniFile%, config, guiWidth, %guiWidthDefault%
	IniRead, guiHeight, %iniFile%, config, guiHeight, %guiHeightDefault%
	
	IniRead, font, %iniFile%, config, font, %fontDefault%
	IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%

	IniRead, internalPreviewWidth, %iniFile%, config, internalPreviewWidth, %internalPreviewWidthDefault%
	IniRead, internalPreviewHeight, %iniFile%, config, internalPreviewHeight, %internalPreviewHeightDefault%
	IniRead, fontsize, %iniFile%, config, fontsize, %fontsizeDefault%
	
	IniRead, clipboardBeepSound, %iniFile%, config, clipboardBeepSound,% ""
	
	IniRead, menuHotkey, %iniFile%, hotkeys, menuHotkey , %menuHotkeyDefault%
	Hotkey, %menuHotkey%, showWindow

	IniRead, exitHotkey, %iniFile%, hotkeys, exitHotkey , %exitHotkeyDefault%
	Hotkey, %exitHotkey%, exit

	IniRead, captureAndResizeHotkey, %iniFile%, hotkeys, captureAndResizeHotkey , %captureAndResizeHotkeyDefault%
	Hotkey, %captureAndResizeHotkey%, captureAndResize

	IniRead, captureAndResizeSaveHotkey, %iniFile%, hotkeys, captureAndResizeSaveHotkey , %captureAndResizeSaveHotkeyDefault%
	Hotkey, %captureAndResizeSaveHotkey%, captureAndResizeSave

	IniRead, setsizeValuesHotkey, %iniFile%, hotkeys, setsizeValuesHotkey , %setsizeValuesHotkeyDefault%
	Hotkey, %setsizeValuesHotkey%, setsizeValues

	IniRead, ocrHotkey, %iniFile%, hotkeys, ocrHotkey , %ocrHotkeyDefault%
	if (ocrHotkey != "")
		Hotkey, %ocrHotkey%, ocr

	IniRead, holdtime, %iniFile%, clipboardresize, holdtime, %holdtimeDefault%
	IniRead, holdtimeshort, %iniFile%, clipboardresize, holdtimeshort, %holdtimeshortDefault%
	IniRead, holdtimelong, %iniFile%, clipboardresize, holdtimelong, %holdtimelongDefault%

	IniRead, showresized, %iniFile%, image, showresized, yes
	
	IniRead, targetWidth, %iniFile%, image, targetwidth, 800
	IniRead, targetHeight, %iniFile%, image, targetheight, 600	
	
	IniRead, filemanager, %iniFile%, external, filemanager, %filemanagerDefault%
	
	IniRead, automodeVari, %iniFile%, operation, automode, true
	
	return
}
;****************************** registerWindow ******************************
registerWindow(){
	global activeWin
	
	activeWin := WinActive("A")
	
	return
}
;******************************** checkFocus ********************************
checkFocus(){
	global activeWin

	h := WinActive("A")
	if (activeWin != h){
		hideWindow()
	}
		
	return
}
; *********************************** showWindow ******************************
showWindow(){
	global guiWidth
	global guiHeight
	
	readIni()
	
	setTimer,checkFocus,3000
	setTimer,registerWindow,-500
	Gui, guiMain:Show, w%guiWidth% h%guiHeight%
	
	return
}
;********************************* hideWindow *********************************
hideWindow(){
	setTimer,checkFocus,delete
	Gui,guiMain:Hide

	return
}
;**************************** showWindowRefreshed ****************************
showWindowRefreshed(){

	readIni()
	showWindow()
	refreshGui()
	
	return
}
;-------------------------------- ClickImage --------------------------------
ClickImage(){
	refreshGui()
	
	return
}
;******************************** refreshGui ********************************
refreshGui(){
	global internalPreviewWidth
	global internalPreviewWidthDefault
	global internalPreviewHeight
	global internalPreviewHeightDefault
	global targetWidth
	global targetHeight
	global font
	global fontsize
	global guiWidth
	global guiHeight
	global PreviewImage
	global InternalPreviewImage
	global msgDefault
	
	deltaY := fontsize * 2 + 4
	
	startGDI()
	pCRBitmap := Gdip_CreateBitmapFromClipboard()
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)

	if (Width > 0 && Height > 0) {
		hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pCRBitmap)
		Gui, guiMain: Default
		GuiControl,guiMain:,InternalPreviewImage,% "HBITMAP:*" hCRBitmap
		DeleteObject(hCRBitmap)
		
		msg := "Captured-image size: " . width . " x " . height . " , resize to: " . targetwidth "  x  " . targetheight
		msgDefault := msg
		showMessage("", msg)
	} else {
		msg := "No new image in clipboard!"
		msgDefault := msg
		showMessage("",msg)
	}
	
	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
		
	return
}
;****************************** saveAutomode ******************************
saveAutomode(){
	global iniFile
	global automodeVari
	
	Gui, guiMain:submit, NoHide

	IniWrite, %automodeVari%, %iniFile%, operation, automode
	
	return
}
; *********************************** openGithubPage ******************************
openGithubPage(){
	global appName
	
	StringLower, name, appName
	Run https://github.com/jvr-ks/%name%
	return
}
; *********************************** ret *******************************
ret() {
	return
}
; *********************************** resize ******************************
resize(){
	global targetWidth
	global targetHeight
	global holdtime
	global automodeVari
	
	OnClipboardChange("OnClipboardChangeFunction",0)
	
	startGDI()
	pCRBitmap := Gdip_CreateBitmapFromClipboard()
		
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)

	if (Width > 0 && Height > 0) {
		resizeFactor := Min(targetWidth/Width, targetHeight/Height)
	
		if (resizeFactor < 1){
			PBitmapResized := Gdip_CreateBitmap(Round(Width*resizeFactor), Round(Height*resizeFactor))
			G := Gdip_GraphicsFromImage(pBitmapResized)
			Gdip_DrawImage(G, pCRBitmap, 0, 0, Round(Width*resizeFactor), Round(Height*resizeFactor), 0, 0, Width, Height)
			
			Gdip_SetBitmapToClipboard(pBitmapResized)
			sleep,500

			Gdip_DisposeImage(PBitmapResized)
			Gdip_DeleteGraphics(G)
		} else {
			showHint("No resize, image is already smaller than target-size!", holdtime)
		}
	}
	
	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
	
	OnClipboardChange("OnClipboardChangeFunction",1)
	showWindowRefreshed()
	
	return
}
;*************************** captureAndResizeStart ***************************
captureAndResizeStart(){

	hideWindow()
	
	sleep, 2000
	
	captureAndResize()
	
	return
}
; *********************************** captureAndResize *******************************
captureAndResize(){
	global targetWidth
	global targetHeight
	global holdtime
	
	OnClipboardChange("OnClipboardChangeFunction",0)
	
	FileType = png
	
	startGDI()
	pCRBitmap := Gdip_BitmapFromScreen()
		
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)
	
	resizeFactor := Min(targetWidth/Width, targetHeight/Height)

	if (Width > 0 && Height > 0) {
		PBitmapResized := Gdip_CreateBitmap(Round(Width*resizeFactor), Round(Height*resizeFactor))
		G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_DrawImage(G, pCRBitmap, 0, 0, Round(Width*resizeFactor), Round(Height*resizeFactor), 0, 0, Width, Height)
		Gdip_DeleteGraphics(G)
		
		Gdip_SetBitmapToClipboard(pBitmapResized)
		sleep, 500
	
		Gdip_DisposeImage(pBitmapResized)
	} else {
		showHint("Image is smaller than target-size!", holdtime)
	}

	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
	
	OnClipboardChange("OnClipboardChangeFunction",1)
			
	showWindowRefreshed()
	
	return
}
;****************************** openFilemanager ******************************
openFilemanager(){
	global saveDir
	global filemanager
	
	if (filemanager := ""){
		cmd := """" . cvtPath(filemanager) . " " .  saveDir . """"
		Run, %comspec% /c %cmd%
	} else {
		cmd := saveDir
		Run, %cmd%
	}

	return
}
;************************* captureAndResizeSaveStart *************************
captureAndResizeSaveStart(){

	hideWindow()

	sleep, 2000
	
	captureAndResizeSave()
	
	return
}
; *********************************** captureAndResize + Save *******************************
captureAndResizeSave(){
	global saveDir
	global targetWidth
	global targetHeight
	global holdtime
	global holdtimeshort
	global holdtimelong
	global saveDir
	
	FileType = png
	
	sleep, 1000
	
	try {
		FileCreateDir, %saveDir%
	} catch e {
		showHint("SEVERE ERROR cannot create directory: " . saveDir . ", closing app!", holdtime)
		exit()
	}
	
	OnClipboardChange("OnClipboardChangeFunction",0)
	
	startGDI()
	pCRBitmap := Gdip_BitmapFromScreen()
	
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)
	
	resizeFactor := Min(targetWidth/Width, targetHeight/Height)
	
	if (resizeFactor < 1){
		PBitmapResized := Gdip_CreateBitmap(Round(Width*resizeFactor), Round(Height*resizeFactor))
		G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_DrawImage(G, pCRBitmap, 0, 0, Round(Width*resizeFactor), Round(Height*resizeFactor), 0, 0, Width, Height)
		Gdip_DeleteGraphics(G)
		
		Gdip_SetBitmapToClipboard(pBitmapResized)
		sleep, 1000
		
		FormatTime, filename, %A_Now% T8, 'screenshot'_yyyy_MM_dd_hh_mm_ss
		Gdip_SaveBitmapToFile(PBitmapResized, saveDir . filename "." FileType)
		msg := "Saved: " . filename "." FileType
	
		Gdip_DisposeImage(PBitmapResized)
	} else {
		showHint("Image is smaller than target-size!", holdtime)
	}
	
	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
	
	OnClipboardChange("OnClipboardChangeFunction",1)
	
	showWindowRefreshed()
	
	return
}
; *********************************** resizeSave *******************************
resizeSave(){
	global targetWidth
	global targetHeight
	global holdtime
	global holdtimeshort
	global holdtimelong
	global saveDir
	global font
	
	FileType = png
	
	try {
		FileCreateDir, %saveDir%
	} catch e {
		showHint("SEVERE ERROR cannot create directory: " . saveDir . ", closing app!", holdtime)
		exit()
	}
	
	OnClipboardChange("OnClipboardChangeFunction",0)
	
	startGDI()
	pCRBitmap := Gdip_CreateBitmapFromClipboard()
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)
	
	resizeFactor := Min(targetWidth/Width, targetHeight/Height)
	
	if (resizeFactor < 1){
		PBitmapResized := Gdip_CreateBitmap(Round(Width*resizeFactor), Round(Height*resizeFactor))
		G := Gdip_GraphicsFromImage(pBitmapResized)
		Gdip_DrawImage(G, pCRBitmap, 0, 0, Round(Width*resizeFactor), Round(Height*resizeFactor), 0, 0, Width, Height)
		
		FormatTime, filename, %A_Now% T8, 'screenshot'_yyyy_MM_dd_hh_mm_ss
		Gdip_SaveBitmapToFile(PBitmapResized, "_savedclips\" . filename "." FileType)
		
		Gdip_SetBitmapToClipboard(pBitmapResized) ; put back resized
		sleep, 1000
		
		Gdip_DisposeImage(pBitmapResized)
		Gdip_DisposeImage(pCRBitmap)
		Gdip_DeleteGraphics(G)
				
		msg := "Saved: " . filename "." FileType
	} else {
		Gdip_DisposeImage(pCRBitmap)
				
		showHint("Image is smaller than target-size!", holdtime)
	}
	
	stopGDI()
	OnClipboardChange("OnClipboardChangeFunction",1)
	
	showWindowRefreshed()
	
	return
}
; *********************************** saveOnly *******************************
saveOnly(){
	global targetWidth
	global targetHeight
	global holdtime
	global holdtimeshort
	global holdtimelong
	global saveDir
	
	FileType = png
	
	try {
		FileCreateDir, %saveDir%
	} catch e {
		showHint("SEVERE ERROR cannot create directory: _savedclips, closing app!", holdtime)
		exit()
	}
	
	startGDI()
	pCRBitmap := Gdip_CreateBitmapFromClipboard()
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)
	

	if (Width > 0 && Height > 0) {	
		pCRBitmap := Gdip_CreateBitmapFromClipboard()

		FormatTime, filename, %A_Now% T8, 'screenshot'_yyyy_MM_dd_hh_mm_ss
		Gdip_SaveBitmapToFile(pCRBitmap, saveDir . filename "." FileType)
	
		msg := "Saved: " . filename "." FileType
		showHint(msg, 2000)
	} else {
		showHint("Clipboard data is not an image!", holdtimeshort)
	}
	
	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
	
	showWindowRefreshed()
	
	return
}
; *********************************** set rsize factor *******************************
setsizeValues(){
	global targetWidth
	global targetHeight
	global iniFile
	global holdtime
	global holdtimeshort
	global holdtimelong
	
	;InputBox, n, Resize-factor Input, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default
	InputBox, targetWidth, Resize: target width:, Please enter target-image width:,,,130,,,,,%targetWidth%
	InputBox, targetHeight, Resize: target height:, Please enter target-image height:,,,130,,,,,%targetHeight%
	
	targetWidth := Max(targetWidth,1)
	targetHeight := Max(targetHeight,1)
	IniWrite, %targetWidth%, %iniFile%, image, targetWidth
	IniWrite, %targetHeight%, %iniFile%, image, targetHeight

	showWindowRefreshed()
	
	return
}
; *********************************** showFullSizeView ******************************
showFullSizeView(){
	global app
	global holdtime
	global holdtimeshort
	global holdtimelong

	pCRBitmap := 0
	x := 0
	y := 0
	
	
	startGDI()
	pCRBitmap := Gdip_CreateBitmapFromClipboard()
	Width := Gdip_GetImageWidth(pCRBitmap)
	Height := Gdip_GetImageHeight(pCRBitmap)
	
	if (Width > 0 && Height > 0) {
		x := Width + 10
		y := Height + 40
		
		Gui, FullSizeView:Destroy
		Gui, FullSizeView:New, +resize +border +MinSize320x240 +MaxSize%x%x%y%
		
		Menu, FullSizeViewMenu, Add, Close clipboard FullSizeView`, open %app%, closeFullSizeView

		Gui, FullSizeView:Menu, FullSizeViewMenu
		
		hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pCRBitmap)
		
		Gui, FullSizeView:Add, Pic,, % "HBITMAP:*" hCRBitmap
		
		message := "FullSizeView clipboard image in real size"
		Gui, FullSizeView:Show,Center,%message%
		
		DeleteObject(hCRBitmap)
	}
	
	Gdip_DisposeImage(pCRBitmap)
	stopGDI()
	
	return
}
; *********************************** closeFullSizeView *******************************
closeFullSizeView(){
	Gui, FullSizeView:Destroy
	
	showWindow()
	
	return
}
; *********************************** cvtPath ******************************
cvtPath(s){
	r := s
	pos := 0

	While pos := RegExMatch(r,"O)(%.+?%)", match, pos+1){
		a := match.1
		r := RegExReplace(r, match.1, envVariConvert(match.1), , 1, pos)
	}
	
	return r
}
; *********************************** envVariConvert ***********************
envVariConvert(s){
	r := s
	if (InStr(s,"%")){
		s := StrReplace(s,"`%","")
		EnvGet, v, %s%
		Transform, r, Deref, %v%
	}

	return r
}
;*************************** guiMainGuiContextMenu ***************************
guiMainGuiContextMenu(GuiHwnd, CtrlHwnd, EventInfo, IsRightClick, X, Y){
	msgBox, 
	(
	A contextmenu is not defined at the moment!
	Parameters are
	GuiHwnd: %GuiHwnd%
	CtrlHwnd: %CtrlHwnd%
	EventInfo: %EventInfo%
	IsRightClick: if(IsRightClick) : "yes","no"
	X: %X%
	Y: %Y%
	)

	return
}
;----------------------------------- exit -----------------------------------
exit() {
	global app
	global posXsave
	global posYsave
	global holdtime
	global holdtimeshort
	global holdtimelong
	global gdiToken
	global MainStatusBarHwnd
	
	Static CCM_SETCOLORSCHEME := 0x2002 ; (CCM_FIRST + 2) lParam is color scheme

	stopGDI()
	
	Gdip_Shutdown(gdiToken)
	Gui, ClipboardResize:Destroy

	tiptop("""" . app . """ closed and removed from memory!")
	
	SendMessage, GuiConstants("CCM_SETBKCOLOR"), 0, 0x9999FF,, ahk_id %MainStatusBarHwnd%
	SendMessage, GuiConstants("WM_CTLCOLOREDIT"), 0, 0xFFFFFF,, ahk_id %MainStatusBarHwnd%
	
	MouseMove, posXsave, posYsave, 0
	OnClipboardChange("OnClipboardChangeFunction",0)
	sleep, 2000
	ExitApp
}


;------------------------------------ ocr ------------------------------------
;Sourcefrom: https://www.autohotkey.com/boards/viewtopic.php?t=18677&p=153056

ocr(){
	global wrkDir
	
	clipboard := 
	
	if (FileExist(wrkDir . "_Capture2Text\Capture2Text_CLI.exe") != ""){
		getSelectionCoords(x_start, x_end, y_start, y_end)
		;x_start := Round(x_start * 96/A_ScreenDPI)
		;x_end := Round(x_end * 96/A_ScreenDPI)
		;y_start := Round(y_start * 96/A_ScreenDPI)
		;y_end := Round(y_end * 96/A_ScreenDPI)
		
		cmd := wrkDir . "_Capture2Text\Capture2Text_CLI.exe --screen-rect "
		quot := """"
		coords := x_start . " " . y_start . " " . x_end . " " . y_end
		;msgbox, coords %coords%
		cmd := cmd  . quot . coords . quot . " -b --clipboard"
		;msgbox, %cmd%
		;clipboard := cmd
		RunWait, %cmd%
		msg := "Clipboard now contains:`n" . clipboard
		tiptopTime(msg, 10000)
		;clipboard := trim(clipboard,"`n`r`t ")
	} else {
		msgbox, Please install`nhttp://capture2text.sourceforge.net/#download`ninto the subdirectory`n_Capture2Text `nfirst!`nThe URL is in the clipboard now!
		clipboard := "http://capture2text.sourceforge.net/#download"
	}
	return
}
;---------------------------- getSelectionCoords ----------------------------
; creates a click-and-drag selection box to specify an area
getSelectionCoords(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end) {
	;Mask Screen
	Gui, Color, FFFFFF
	Gui +LastFound
	WinSet, Transparent, 50
	Gui, -Caption 
	Gui, +AlwaysOnTop
	Gui, Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%,"AutoHotkeySnapshotApp"     

	;Drag Mouse
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	WinGet, hw_frame_m,ID,"AutoHotkeySnapshotApp"
	hdc_frame_m := DllCall( "GetDC", "uint", hw_frame_m)
	KeyWait, LButton, D 
	MouseGetPos, scan_x_start, scan_y_start 
	Loop
	{
		Sleep, 10   
		KeyIsDown := GetKeyState("LButton")
		if (KeyIsDown = 1)
		{
			MouseGetPos, scan_x, scan_y 
			DllCall( "gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", 0,"int",0,"int", A_ScreenWidth,"int",A_ScreenHeight)
			DllCall( "gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", scan_x_start,"int",scan_y_start,"int", scan_x,"int",scan_y)
		} else {
			break
		}
	}

	;KeyWait, LButton, U
	MouseGetPos, scan_x_end, scan_y_end
	Gui Destroy
	
	if (scan_x_start < scan_x_end)
	{
		x_start := scan_x_start
		x_end := scan_x_end
	} else {
		x_start := scan_x_end
		x_end := scan_x_start
	}
	
	if (scan_y_start < scan_y_end)
	{
		y_start := scan_y_start
		y_end := scan_y_end
	} else {
		y_start := scan_y_end
		y_end := scan_y_start
	}
	
	return
}	