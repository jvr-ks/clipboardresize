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


#NoEnv
#Warn
#SingleInstance Force

#InstallKeybdHook

#Include %A_ScriptDir%

#Include, Lib\gdipAllpatched.ahk
#Include, Lib\hotkeyToText.ahk

CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, ToolTip, Screen

tipOffsetDeltaX := 0
startDelayAfterClipboardChange := 100
autoResize := true
autoSave := false
autoSaveFullsize := false
useActivator := true
autoHide := false
ocrmode := false

msgDefault := ""

MainStatusBarHwnd := 0

gdiToken := 0

SendMode Input 
SetWorkingDir %A_ScriptDir%

wrkDir := A_ScriptDir . "\"
saveDir := wrkDir . "_savedclips\"

appName := "ClipboardResize"
appVersion := "0.177"
app := appName . " " . appVersion
appnameLower := "clipboardresize"
appExtension := ".exe"
extension := ".exe"


clientWidth := 0
clientHeight := 0
sizeW := 0

CR := "`n"
CR := CR . CR

bit := (A_PtrSize=8 ? "64" : "32")

if (!A_IsUnicode)
  bit := "A" . bit

bitName := (bit="64" ? "" : bit)

app := appName . " " . appVersion . " (" . bit . " bit)"

server := "https://github.com/jvr-ks/" . appnameLower . "/raw/main/"
downLoadURL := server . appnameLower . bitName . appExtension
downLoadFilename := appnameLower . ".exe.tmp"
restartFilename := "restart.bat"
downLoadURLrestart := server . restartFilename


configFile := A_ScriptDir . "\clipboardresize.ini"

posXsave := 0
posYsave := 0

MouseGetPos, posXsave, posYsave

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

filemanager := ""


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

ocrHotkeyDefault := "!y"
ocrHotkey := ocrHotkeyDefault

winHotkeyAliasDefault := "!z"
winHotkeyAlias := winHotkeyAliasDefault
winHotkeyAliasEnable := 1

captureAreaHotkeyDefault := "^!z"
captureAreaHotkey := captureAreaHotkeyDefault

openFilemanagerHotkeyDefault := "+!z"
openFilemanagerHotkey := openFilemanagerHotkeyDefault

targetWidth := 800
targetHeight := 600

clipboardBeepSound := ""

imagesInColumn := 5
imagesInRow := 3
imagesPerPage := imagesInColumn * imagesInRow
pageIndexStart := 0
page := 1
maxIndex := 0
filesArr := []
cursorChanged := 0
tooltipText := ""

OnExit("resetCursor")

msg_control_string = If checked:`nAn automatic resize operation is executed`nif a new clipboard-image is detected!,automodeVari

readConfig()

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
  tipTop(app . " started, hotkey is: " . hotkeyToText(menuHotkey), 4000)
  activatorWindow()
  mainWindow(true)
} else {
  activatorWindow()
  mainWindow()
}

return
;-------------------------------- resetCursor --------------------------------
resetCursor(){
  global cursorChanged

  if (cursorChanged)
    changeCursor()

  return
}
;------------------------------- changeCursor -------------------------------
changeCursor(){
  global cursorChanged

  NULL=
  IDC_APPSTARTING := 32650
  IDC_HAND := 32649
  IDC_ARROW := 32512
  IDC_CROSS := 32515
  IDC_IBEAM := 32513
  IDC_ICON := 32641
  IDC_NO := 32648
  IDC_SIZE := 32640
  IDC_SIZEALL := 32646
  IDC_SIZENESW := 32643
  IDC_SIZENS := 32645
  IDC_SIZENWSE := 32642
  IDC_SIZEWE := 32644
  IDC_UPARROW := 32516
  IDC_WAIT := 32514

  result1 := DllCall("LoadCursor", "Uint", NULL, "Int", IDC_CROSS, "Uint")
  result2 := DllCall("SetSystemCursor", "Uint", result1, "Int", IDC_ARROW, "Uint")
  cursorChanged := !cursorChanged
  
  return
}
;------------------------------ winHotkeyAlias ------------------------------
winHotkeyAliasPress(){

  sendInput +#{s}

  return
}
;------------------------------ guiMainGuiSize ------------------------------
guiMainGuiSize(){
  global clientWidth, clientHeight
  
  clientWidth := A_GuiWidth
  clientHeight := A_GuiHeight
  
  return
}
;----------------------------- imagesGuiGuiSize -----------------------------
imagesGuiGuiSize(){
  global clientWidth_imagesGui, clientHeight_imagesGui

  clientWidth_imagesGui := A_GuiWidth
  clientHeight_imagesGui := A_GuiHeight
  
  return
}
;------------------------------ activatorWindow ------------------------------
activatorWindow(){
  global appName, activatorButton
  
  setTimer, checkFocus, delete
  
  buttonWidth := 120
  
  gui, guiActivator:Destroy
  gui, guiActivator:New,+E0x08000000 -Caption -Border -SysMenu +AlwaysOnTop +ToolWindow +HwndGuiActivatorHwnd
  gui, guiActivator:Margin, 0, 0
  gui, guiActivator:Add,button,VactivatorButton x0 y0 w%buttonWidth% GshowWindowFromActivator,%appName%

  gui, guiActivator:Show, xcenter y55 autosize
  
  gui, guiActivator:Hide
  
  return
}
;-------------------------- showWindowFromActivator --------------------------
showWindowFromActivator(){
  global mainHWND
  
  gui, guiActivator:Hide
  setTimer, hideWindow, delete
  showWindowForced()

  return
}
;----------------------------- showWindowForced -----------------------------
showWindowForced(){

  gui, guiMain:Show, autosize
  
  setTimer, checkFocus, delete
  setTimer, checkFocus, 3000

  return
}
;-------------------------------- mainWindow --------------------------------
mainWindow(hide := false) {
  global app, appName, font
  global fontsize, targetWidth
  global targetHeight
  global menuHotkey, exitHotkey

  global captureAndResizeHotkey, captureAndResizeSaveHotkey, setsizeValuesHotkey
  
  global internalPreviewWidth, internalPreviewHeight
  global MainStatusBarHwnd, automodeVari, appVersion
  global InternalPreviewImage, msgDefault
  global mainHWND, targetSize, CR, autoResize, autoSave, autoSaveFullsize, useActivator, autoHide, sizeValues
  
  gui, guiMain:destroy
    
  ; Move to menuposition
  WinGetPos, winTopL_x, winTopL_y, width, height, A
  winCenter_x := winTopL_x + width/2
  ;winCenter_y := winTopL_y + height/2
  ;MouseMove, winCenter_x - 500, 100, 0
  DllCall("SetCursorPos", int, winCenter_x - 500, int, 100)

  showFullSizeViewText := "Fullsize View"
 
  menu, Tray, UseErrorLevel   ; This affects all menus, not just the tray.

  menu, MainMenu, NoDefault
  menu, MainMenu, DeleteAll
  
  menu, MainMenuOperations, Add, Resize only, resize
  
  menu, MainMenuUpdate, Add, Check if new version is available, checkUpdate
  menu, MainMenuUpdate, Add, Start updater, updateApp
  
  
  menu, MainMenu, Add, Operations,:MainMenuOperations
  
  menu, MainMenu, Add, %showFullSizeViewText%, showFullSizeView
  
  menu, MainMenu, Add, Update,:MainMenuUpdate
    
  menu, MainMenu, Add, Github,openGithubPage

  menu, MainMenu, Add, Kill the app, exit
  
  buttonWidth := 120

  gui, guiMain:New, +OwnDialogs +LastFound +ToolWindow -MaximizeBox -MinimizeBox HwndmainHWND, %app%

  gui, guiMain:Font, s%fontsize%, %font%

  gui, guiMain:Add, StatusBar, hwndMainStatusBarHwnd -Theme +BackgroundSilver
  
  
  gui, guiMain:Add, Button, xm ym w%buttonWidth% Default GsnippingTool, Snipping Tool
  gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% gresizeSave,Resize and save
  gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% GimagePreviewShow, Saved-clips preview
  gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% VsizeValues GsetSizeValues,Resize to (%targetwidth% x %targetheight%)
  
  gui, guiMain:Add, Button, xm w%buttonWidth% gcaptureAndResizeStart, Capture`, resize
  gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% gcaptureAndResizeSaveStart, Capture`, resize`, save
  gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% GopenFilemanager vFilemanager, Saved-clips Fileman.
  gui, guiMain:Add, Button, x+m yp+0 w%buttonWidth% gmenuSaveOnly,Save only
  
  chk := autoResize ? "checked" : ""
  gui, guiMain:Add, CheckBox, section xm VautoResize GsaveAutoResize %chk%, Auto-Resize
  
  chk := autoSave ? "checked" : ""
  gui, guiMain:Add, CheckBox, section x+m yp+0 VautoSave GsaveAutoSave %chk%, Auto-Save
  
  chk := autoSaveFullsize ? "checked" : ""
  gui, guiMain:Add, CheckBox, section x+m yp+0 VautoSaveFullsize GsaveAutoSaveFullsize %chk%, Auto-Save (fullsize)
    
  chk := useActivator ? "checked" : ""
  gui, guiMain:Add, CheckBox, section x+m yp+0 VuseActivator GsaveUseActivator %chk%, Activator-button
  
  chk := autoHide ? "checked" : ""
  gui, guiMain:Add, CheckBox, x+m yp+0 VautoHide GsaveAutoHide %chk%, Auto-hide

  
  startGDI()
  pCRBitmap := Gdip_CreateBitmapFromClipboard()
  Width := Gdip_GetImageWidth(pCRBitmap)
  Height := Gdip_GetImageHeight(pCRBitmap)

  if (Width > 0 && Height > 0) {
    resizeFactor := Min(internalPreviewWidth/Width, internalPreviewHeight/Height)
    newWidth :=  Round(Width * resizeFactor)
    newHeight := Round(Height * resizeFactor)
    
    PBitmapResized := Gdip_CreateBitmap(newWidth, newHeight)
    G := Gdip_GraphicsFromImage(pBitmapResized)
    Gdip_DrawImage(G, pCRBitmap, 0, 0, newWidth, newHeight, 0, 0, Width, Height)
    
    hCRBitmap := Gdip_CreateHBITMAPFromBitmap(PBitmapResized)

    gui, guiMain:Add, Pic, x5 w%newWidth% h-1 vInternalPreviewImage gClickImage,% "HBITMAP:*" hCRBitmap
  
    DeleteObject(hCRBitmap)
    
    msg := "Image in clipboard size is: " . Width "  x  " . Height 
    msgDefault := msg
    showMessage("", msg)
  } else {
    msg := "No image in clipboard!"
    msgDefault := msg
    showMessage("", msg)
    
    gui, guiMain:Add, Pic, x5 w%internalPreviewWidth% h%internalPreviewHeight% vInternalPreviewImage gClickImage, noImage.png
  }

  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
    
  gui, guiMain:Menu, MainMenu
  
  gui, guiMain:Show, autosize
  
  if (hide){
    gui, guiMain:Hide
  }
  
  return
}
guiMainGuiClose(){
  tipTop("The app is moved to the background only, use the button ""Kill the app"" to exit the app!", 5000)

  return
}
;-------------------------------- showHotkeys --------------------------------
showHotkeys(){
  msgbox, todo

  return
}
;-------------------------------- checkFocus --------------------------------
checkFocus(){
  global mainHWND

  h := WinActive("A")
  if (mainHWND != h){
    hideWindow()
  }
    
  return
}

;----------------------------- showErrorMessage -----------------------------
showErrorMessage(msg){

  showMessage("", msg)
  
  return
}
      
;------------------------- OnClipboardChangeFunction -------------------------
OnClipboardChangeFunction(type){
  global wrkDir, startDelayAfterClipboardChange
  global ocrmode, holdtime, holdtimelong, clipboardBeepSound, autoResize
  global useActivator, autoSave, autoSaveFullsize, autoHide
  
  OnClipboardChange("OnClipboardChangeFunction", 0)
  
  nameModifier := ""
  
  if (clipboardBeepSound != ""){
    f := cvtPath(clipboardBeepSound)
    SoundPlay, %f%
  }
  
  ; only type images 
  if (type == 2){
    sleep, startDelayAfterClipboardChange

    FormatTime, name, %A_Now% T8, 'clpr'_yyyy_MM_dd_hh_mm_ss
    
    capsStatus := getkeystate("Capslock","T")
    if (capsStatus){
      autoResize := 0
      nameModifier := ""
      tipTop("Capslock is on, no autoresize!")
    }
    
    if (autoSaveFullsize){
      saveOnly(true, name . nameModifier)
     }

    if (autoResize){
      resize()
    }
    
    if (autoSave && autoResize){
      saveOnly(false, name)
    }
    
    showWindowRefreshed()
    
    if (autoHide){
      setTimer, hideWindow, delete
      setTimer, hideWindow, -2000
    }
  }
  
  setTimer, activatorWindowHide, delete
  setTimer, activatorWindowHide, -10000
  
  OnClipboardChange("OnClipboardChangeFunction", 1)

  refreshPreview()
  
  return
}
;------------------------------ refreshPreview ------------------------------
refreshPreview(){

  if (WinExist("Saved-clips preview") > 0){
    imagePreviewShow()
    gui, guiMain:Show, autosize
  }

  return
}
;--------------------------- activatorWindowHide ---------------------------
activatorWindowHide(){

  gui, guiActivator:Hide

  return
}
;********************************* startGDI *********************************
startGDI(){
  global gdiToken

  if (gdiToken != 0){
    tipTop("Gdi already running!", 3000)
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
;-------------------------------- iniReadSave --------------------------------
iniReadSave(name, section, defaultValue){
  global configFile
  
  r := ""
  IniRead, r, %configFile%, %section%, %name%, %defaultValue%
  if (r == "" || r == "ERROR")
    r := defaultValue
    
  if (r == "#empty!")
    r := ""
    
  return r
}
; *********************************** readConfig *******************************
readConfig(){
  global configFile, targetWidth, targetHeight
  global menuHotkeyDefault, menuHotkey, exitHotkeyDefault, exitHotkey
  global resizeOnlyHotkeyDefault, resizeOnlyHotkey, captureAndResizeHotkeyDefault, captureAndResizeHotkey
  global captureAndResizeSaveHotkeyDefault, captureAndResizeSaveHotkey, ocrHotkeyDefault
  global ocrHotkey, setsizeValuesHotkeyDefault, setsizeValuesHotkey, openFilemanagerHotkeyDefault, openFilemanagerHotkey
  global holdtimeDefault, holdtime, holdtimeshortDefault, holdtimeshort, holdtimelongDefault, holdtimelong
  global filemanager
  global fontDefault, font, fontsizeDefault, fontsize
  global internalPreviewWidth, internalPreviewWidthDefault, internalPreviewHeight, internalPreviewHeightDefault

  global clipboardBeepSound, targetSize, autoResize, autoSave, autoSaveFullsize
  global useActivator, autoHide, page
  global winHotkeyAliasEnable, winHotkeyAliasDefault, winHotkeyAlias
  global captureAreaHotkey, captureAreaHotkeyDefault
  
  global tesseractPath, lang, psm, imagenameTmp, tesseracOutputbase
  
  font := iniReadSave("font", "config", fontDefault)
  fontsize := iniReadSave("fontsize", "config", fontsizeDefault)

  internalPreviewWidth := iniReadSave("internalPreviewWidth", "config", internalPreviewWidthDefault)
  internalPreviewHeight := iniReadSave("internalPreviewHeight", "config", internalPreviewHeightDefault)
  fontsize := iniReadSave("fontsize", "config", fontsizeDefault)
  
  clipboardBeepSound := iniReadSave("clipboardBeepSound", "config",  "")
  
  menuHotkey := iniReadSave("menuHotkey", "hotkeys", menuHotkeyDefault)
  Hotkey, %menuHotkey%, showWindowForced, On

  exitHotkey := iniReadSave("exitHotkey", "hotkeys", exitHotkeyDefault)
  Hotkey, %exitHotkey%, exit, On

  captureAndResizeHotkey := iniReadSave("captureAndResizeHotkey", "hotkeys", captureAndResizeHotkeyDefault)
  Hotkey, %captureAndResizeHotkey%, captureAndResize, On

  captureAndResizeSaveHotkey := iniReadSave("captureAndResizeSaveHotkey", "hotkeys", captureAndResizeSaveHotkeyDefault)
  Hotkey, %captureAndResizeSaveHotkey%, captureAndResizeSave, On

  setsizeValuesHotkey := iniReadSave("setsizeValuesHotkey", "hotkeys", setsizeValuesHotkeyDefault)
  Hotkey, %setsizeValuesHotkey%, setsizeValues, On

  ocrHotkey := iniReadSave("ocrHotkey", "hotkeys", ocrHotkeyDefault)
  Hotkey, %ocrHotkey%, ocr, On
  
  openFilemanagerHotkey := iniReadSave("openFilemanagerHotkey", "hotkeys", openFilemanagerHotkeyDefault)
  Hotkey, %openFilemanagerHotkey%, openFilemanager, On
  
  holdtime := iniReadSave("holdtime", "clipboardresize", holdtimeDefault)
  holdtimeshort := iniReadSave("holdtimeshort", "clipboardresize", holdtimeshortDefault)
  holdtimelong := iniReadSave("holdtimelong", "clipboardresize", holdtimelongDefault)
 
  targetWidth := iniReadSave("targetWidth", "image", 800)
  targetHeight := iniReadSave("targetHeight", "image", 600 )
  
  GuiControl,guiMain:,targetSize, Targetsize (width x height): %targetwidth% x %targetheight%
  
  filemanager := iniReadSave("filemanager", "external", "")
  
  autoResize := iniReadSave("autoResize", "operation", 0)
  autoSave := iniReadSave("autoSave", "operation", 0)
  autoSaveFullsize := iniReadSave("autoSaveFullsize", "operation", 0)
  useActivator := iniReadSave("useActivator", "operation", 0)
  autoHide := iniReadSave("autoHide", "operation", 0)
  
  page := iniReadSave("page", "operation", 1)
  
  winHotkeyAliasEnable := iniReadSave("winHotkeyAliasEnable", "config", 0)
  winHotkeyAlias := iniReadSave("winHotkeyAlias", "hotkeys", winHotkeyAliasDefault)
  
  if (winHotkeyAliasEnable){
    Hotkey, %winHotkeyAlias%, winHotkeyAliasPress, On
  } else {
    Hotkey, %winHotkeyAlias%, captureAreaToClipboard, On
  }
  captureAreaHotkey := iniReadSave("captureAreaHotkey", "hotkeys", captureAreaHotkeyDefault)
  if (captureAreaHotkey != "")
    Hotkey, %captureAreaHotkey%, captureAreaToClipboard, On

  tesseractPath := iniReadSave("tesseractPath", "tesseract", "C:\Program Files\Tesseract-OCR\tesseract.exe")
  lang := iniReadSave("lang", "tesseract", "eng+deu")
  psm := iniReadSave("psm", "tesseract", 6 )
  imagenameTmp := iniReadSave("imagenameTmp", "tesseract", "_tmp.png")
  tesseracOutputbase := iniReadSave("tesseracOutputbase", "tesseract", "tmp")

  return
}
;-------------------------------- showWindow --------------------------------
showWindow(n := 3000){
  global useActivator

  readConfig()
  
  if (useActivator){
    gui, guiActivator:Show
    setTimer, activatorWindowHide, delete
    t := -1 * n
    setTimer, activatorWindowHide, %t%
  } else {
    gui, guiActivator:Hide
    gui, guiMain:Show
  }  
  
  return
}
;********************************* hideWindow *********************************
hideWindow(){

  gui, guiMain:Hide
  setTimer, checkFocus, delete
  
  return
}
;---------------------------- showWindowRefreshed ----------------------------
showWindowRefreshed(n := 3000){
  global useActivator

  readConfig()
  
  if (useActivator){
    gui, guiActivator:Show
    setTimer, activatorWindowHide, delete
    t := -1 * n
    setTimer, activatorWindowHide, %t%
  } else {
    gui, guiActivator:Hide
    gui, guiMain:Show,autosize
    setTimer, checkFocus, 3000
  } 
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
  global internalPreviewWidth, internalPreviewWidthDefault, internalPreviewHeight, internalPreviewHeightDefault
  global targetWidth, targetHeight
  global font, fontsize
  global PreviewImage, InternalPreviewImage
  global msgDefault
   
  startGDI()
  pCRBitmap := Gdip_CreateBitmapFromClipboard()
  
  Width := Gdip_GetImageWidth(pCRBitmap)
  Height := Gdip_GetImageHeight(pCRBitmap)

  if (Width > 0 && Height > 0) {
    G := Gdip_GraphicsFromImage(pCRBitmap)
    Gdip_DrawImage(G, pCRBitmap, 0, 0, Width, Height, 0, 0, Width, Height)
    hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pCRBitmap)

    gui, guiMain: Default
    GuiControl,guiMain:,InternalPreviewImage,% "HBITMAP:*" hCRBitmap
  
    DeleteObject(hCRBitmap)
    Gdip_DeleteGraphics(G)
    
    msg := "Image size: " . width . " x " . height
    msgDefault := msg
    showMessage("", msg)
  } else {
    msg := "No image in clipboard!"
    msgDefault := msg
    showMessage("", msg)
    
    GuiControl,,InternalPreviewImage,noImage.png
  }

  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
    
  return
}

;------------------------------ saveAutoResize ------------------------------
saveAutoResize(){
  global configFile, autoResize
  
  gui, guiMain:submit, NoHide

  IniWrite, %autoResize%, %configFile%, operation, autoResize
  
  return
}

;------------------------------- saveAutoSave -------------------------------
saveAutoSave(){
  global configFile, autoSave
  
  gui, guiMain:submit, NoHide

  IniWrite, %autoSave%, %configFile%, operation, autoSave  
  
  return
}
;--------------------------- saveAutoSaveFullsize ---------------------------
saveAutoSaveFullsize(){
  global configFile
  global autoSaveFullsize
  
  gui, guiMain:submit, NoHide
  
  IniWrite, %autoSaveFullsize%, %configFile%, operation, autoSaveFullsize  
  
  return
}
;----------------------------- saveUseActivator -----------------------------
saveUseActivator(){
  global configFile, useActivator, autoHide
  
  gui, guiMain:submit, NoHide

  IniWrite, %useActivator%, %configFile%, operation, useActivator 
  
  if (useActivator){
    gui, guiActivator:Show
    setTimer, activatorWindowHide, delete
    setTimer, activatorWindowHide, -3000
  }
  
  return
}
;------------------------------ saveAutoHide ------------------------------
saveAutoHide(){
  global configFile, autoHide, useActivator
  
  gui, guiMain:submit, NoHide
  
  IniWrite, %autoHide%, %configFile%, operation, autoHide 
  
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
  global targetWidth, targetHeight
  global holdtime, autoResize, msgDefault
  
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

      ;read again
      pCRBitmap := Gdip_CreateBitmapFromClipboard()
    
      Width := Gdip_GetImageWidth(pCRBitmap)
      Height := Gdip_GetImageHeight(pCRBitmap)

      Gdip_DisposeImage(PBitmapResized)
      Gdip_DeleteGraphics(G)
      
      msg := "Image in clipboard size is: " . Width "  x  " . Height 
      msgDefault := msg
      showMessage("", msg)
    } else {
      tipTop("No resize, image is already smaller than target-size!", holdtime)
    }
  }
  
  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
  
  OnClipboardChange("OnClipboardChangeFunction",1)
  
  return
}
;------------------------------- snippingTool -------------------------------
snippingTool(){
  global autoSaveFullsize

  hideWindow()
  
  Run %A_WinDir%\system32\SnippingTool.exe
  
  return
}
;*************************** captureAndResizeStart ***************************
captureAndResizeStart(){

  hideWindow()
  
  sleep, 1000
  
  captureAndResize()
  
  return
}
; *********************************** captureAndResize *******************************
captureAndResize(){
  global targetWidth, targetHeight, holdtime
  
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
    tipTop("Image is smaller than target-size!", holdtime)
  }

  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
  
  OnClipboardChange("OnClipboardChangeFunction",1)
      
  showWindowRefreshed()
  
  return
}

;------------------------------ openFilemanager ------------------------------
openFilemanager(){
  global saveDir, filemanager
  
  if (filemanager == "" || filemanager == "ERROR"){
    Run, explore %saveDir%
  } else {
    if (InStr(filemanager, "dopusrt")){
      cmd := """" . filemanager . """" . " /cmd go "  . """" . saveDir . """"
      hideWindow()
      RunWait, %cmd%  
    } else {
      msgbox, Unknown Filemanager:`n%filemanager%
    }
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
  global saveDir, targetWidth, targetHeight
  global holdtime, holdtimeshort, holdtimelong
  global saveDir
  
  FileType = png
  nameModifier := ""
  
  sleep, 1000
  
  try {
    FileCreateDir, %saveDir%
  } catch e {
    tipTop("SEVERE ERROR cannot create directory: " . saveDir . "`, closing app!", holdtime)
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
    
    FormatTime, filename, %A_Now% T8, 'clpr'_yyyy_MM_dd_hh_mm_ss'
    nameModifier := "_rs"
    
    Gdip_SaveBitmapToFile(PBitmapResized, saveDir . filename "." FileType)
    msg := "Saved: " . filename . nameModifier . "." FileType
  
    Gdip_DisposeImage(PBitmapResized)
  } else {
    tipTop("Image is smaller than target-size!", holdtime)
  }
  
  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
  
  OnClipboardChange("OnClipboardChangeFunction",1)
  
  showWindowRefreshed()
  
  refreshPreview()

  
  return
}
; *********************************** resizeSave *******************************
resizeSave(){
  global targetWidth, targetHeight
  global holdtime, holdtimeshort, holdtimelong, saveDir, font
  
  FileType = png
  nameModifier := ""
  
  try {
    FileCreateDir, %saveDir%
  } catch e {
    tipTop("SEVERE ERROR cannot create directory: " . saveDir . "`, closing app!", holdtime)
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
    
    FormatTime, filename, %A_Now% T8, 'clpr'_yyyy_MM_dd_hh_mm_ss'
    nameModifier := "_rs"
    
    Gdip_SaveBitmapToFile(PBitmapResized, "_savedclips\" . filename . nameModifier . "." FileType)
    
    Gdip_SetBitmapToClipboard(pBitmapResized) ; put back resized
    sleep, 1000
    
    Gdip_DisposeImage(pBitmapResized)
    Gdip_DisposeImage(pCRBitmap)
    Gdip_DeleteGraphics(G)
        
    msg := "Saved: " . filename "." FileType
  } else {
    Gdip_DisposeImage(pCRBitmap)
        
    tipTop("Image is smaller than target-size!", holdtime)
  }
  
  stopGDI()
  OnClipboardChange("OnClipboardChangeFunction",1)
  
  showWindowRefreshed()
  
  refreshPreview()

  
  return
}

;------------------------------- menuSaveOnly -------------------------------
menuSaveOnly(){
  FormatTime, name, %A_Now% T8, 'clpr'_yyyy_MM_dd_hh_mm_ss
  saveOnly(false, name)

  return
}
; *********************************** saveOnly *******************************
saveOnly(fullsize := false, name := "dummy.png" ){
  global targetWidth, targetHeight
  global holdtime, holdtimeshort, holdtimelong
  global saveDir
  
  FileType = png
  
  try {
    FileCreateDir, %saveDir%
  } catch e {
    tipTop("SEVERE ERROR cannot create directory: _savedclips, closing app!", holdtime)
    exit()
  }
  
  startGDI()
  pCRBitmap := Gdip_CreateBitmapFromClipboard()
  Width := Gdip_GetImageWidth(pCRBitmap)
  Height := Gdip_GetImageHeight(pCRBitmap)
  
  if (Width > 0 && Height > 0) {  
    pCRBitmap := Gdip_CreateBitmapFromClipboard()
    
    if (fullsize)
      filename := name
    else
      filename := name . "_rs"
      
    Gdip_SaveBitmapToFile(pCRBitmap, saveDir . filename "." FileType)
  
    msg := "Saved: " . filename "." FileType
    tipTop(msg, 2000)
  } else {
    tipTop("Clipboard data is not an image!", holdtimeshort)
  }
  
  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
  
  refreshPreview()
  
  return
}
; *********************************** set rsize factor *******************************
setsizeValues(){
  global targetWidth, targetHeight
  global configFile, holdtime, holdtimeshort, holdtimelong
  global sizeValues
  
  ;InputBox, n, Resize-factor Input, Prompt, HIDE, Width, Height, X, Y, Locale, Timeout, Default
  InputBox, targetWidth, Resize: target width:, Please enter target-image width:,,,130,,,,,%targetWidth%
  InputBox, targetHeight, Resize: target height:, Please enter target-image height:,,,130,,,,,%targetHeight%
  
  targetWidth := Max(targetWidth,1)
  targetHeight := Max(targetHeight,1)
  IniWrite, %targetWidth%, %configFile%, image, targetWidth
  IniWrite, %targetHeight%, %configFile%, image, targetHeight

  showWindowRefreshed()
  guicontrol,text,sizeValues,Resize to (%targetwidth% x %targetheight%)
  
  return
}
; *********************************** showFullSizeView ******************************
showFullSizeView(){
  global appName
  global holdtime, holdtimeshort, holdtimelong

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
    
    gui, FullSizeView:Destroy
    gui, FullSizeView:New, +resize +border +MinSize320x240 +MaxSize%x%x%y%
    
    menu, FullSizeViewMenu, Add, Close Fullsize View`, reopen %appName%, closeFullSizeView

    gui, FullSizeView:Menu, FullSizeViewMenu
    
    hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pCRBitmap)
    
    gui, FullSizeView:Add, Pic,, % "HBITMAP:*" hCRBitmap
    
    message := "FullSizeView clipboard image in real size"
    gui, FullSizeView:Show,Center,%message%
    
    DeleteObject(hCRBitmap)
  }
  
  Gdip_DisposeImage(pCRBitmap)
  stopGDI()
  
  return
}
; *********************************** closeFullSizeView *******************************
closeFullSizeView(){
  gui, FullSizeView:Destroy
  
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
  global CR, CR2
  global menuHotkey, captureAndResizeHotkey, captureAndResizeSaveHotkey, setsizeValuesHotkey
  global exitHotkey

  HotkeyText := "Hotkeys: " . CR
  HotkeyText .= "Capture area: [ALT] + [z]" . CR
  HotkeyText .= "Show app: " . hotkeyToText(menuHotkey) . CR
  HotkeyText .= "Capture, resize: " . hotkeyToText(captureAndResizeHotkey) . CR
  HotkeyText .= "Capture`, resize`, save: " . hotkeyToText(captureAndResizeSaveHotkey) . CR
  HotkeyText .= "Set target-size: "  . hotkeyToText(setsizeValuesHotkey) . CR
  HotkeyText .= "Kill app: " . hotkeyToText(exitHotkey)
  
  msgBox, %HotkeyText%

  return
}

;-------------------------------- updateApp --------------------------------
updateApp(){
  global wrkdir, appname, bitName, extension

  updaterExeVersion := "updater" . bitName . extension
  
  if(FileExist(updaterExeVersion)){
    msgbox, Starting "Updater" now, please restart "%appname%" afterwards!
    run, %updaterExeVersion% runMode
    exit()
  } else {
    msgbox, SEVERE ERROR: %updaterExeVersion% not found!
  }
  
  showWindowForced()

  return
}

;----------------------------------- exit -----------------------------------
exit() {
  global app
  global posXsave, posYsave
  global holdtime, holdtimeshort, holdtimelong
  global gdiToken, MainStatusBarHwnd
  
  Static CCM_SETCOLORSCHEME := 0x2002 ; (CCM_FIRST + 2) lParam is color scheme

  tipTop("""" . app . """ closed and removed from memory!")
  
  stopGDI()
  
  Gdip_Shutdown(gdiToken)
  gui, ClipboardResize:Destroy
  
  MouseMove, posXsave, posYsave, 0
  OnClipboardChange("OnClipboardChangeFunction",0)
  ExitApp
}
;------------------------------------ ocr ------------------------------------
ocr(){
  global gdiToken, holdtime, holdtimelong, wrkDir
  global tesseractPath, lang, psm, imagenameTmp, tesseracOutputbase
  
  changeCursor()
  ttText := "
  (
    OCR: Press and hold the [Alt]-key,
    then click on top-left of the text-area and
    hold down the [Alt]-key while moving the mouse,
    but do NOT drag the mouse.
    Release the [Alt]-key if the area is completely marked!
  )"

  tooltipFollowMouseOn(ttText)

  startGDI()
  
  Gui, overlay:New, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs HWNDoverlayHWND
  Gui, overlay:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%
  
  hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
  hdc := CreateCompatibleDC()
  obm := SelectObject(hdc, hbm)
  theGraphics := Gdip_GraphicsFromHDC(hdc)
  Gdip_SetSmoothingMode(theGraphics, 4)
  
  theBrush := Gdip_BrushCreateSolid(0x660000ff)
  
  imgx := 0
  imgy := 0
  height := 0
  width := 0

  thePen := Gdip_CreatePen(0xffff0000, 3)

  KeyWait, LButton, D
  tooltipFollowMouseOff()
  mouseGetPos, x1, y1

  ;while getKeyState("LButton", "P"){
  downYKey := GetKeyState("Alt", "P")
  while (downYKey) {
    mouseGetPos, x2, y2
    Gdip_GraphicsClear(theGraphics)
    
    imgx := min(x1, x2)
    imgy := min(y1, y2)
    width := abs(x2 - x1)
    height := abs(y2 - y1)
    
    Gdip_FillRoundedRectangle(theGraphics, theBrush, imgx, imgy, width, height, 2)
    UpdateLayeredWindow(overlayHWND, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
    sleep, 100
    downYKey := GetKeyState("Alt", "P")
  }

  tooltipFollowMouseOff()
  resetCursor()
  
  Gui, overlay:Destroy

  Image := Gdip_Bitmapfromscreen(imgx "|" imgy "|" width "|" height)
  
  Gdip_Savebitmaptofile(Image, imagenameTmp)
  Gdip_DisposeImage(Image)
  
  Gdip_DeleteBrush(theBrush)
  SelectObject(hdc, obm)
  DeleteObject(hbm)
  DeleteDC(hdc)
  Gdip_DeleteGraphics(theGraphics)
  StopGDI()
  
; OCR:
  txtExtension :=  ".txt"
  outputfile := wrkDir . tesseracOutputbase . txtExtension
  
  if (FileExist(outputfile))
    FileDelete, %outputfile% 

  if (FileExist(tesseractPath)){
    runWait %tesseractPath% %imagenameTmp% %tesseracOutputbase% -l %lang% --psm %psm%,, Hide
    data := ""
    if (FileExist(outputfile)){
      FileRead, data, %outputfile%
      if (!ErrorLevel){
        tipTop(data, holdtimelong)
        clipboard := data
      } else {
        tipTop("OCR-error occured, something went wrong!", holdtime)
      }
    } else {
      tipTop("Tesseract-error occured, produced no output!", holdtime)
    }
  } else {
    tipTop("Tesseract installation missing, file " . tesseractPath . " not found!", holdtime)
  }

  return
}
;-------------------------- captureAreaToClipboard --------------------------
captureAreaToClipboard(){
  ; image
  global gdiToken, holdtime, holdtimelong, wrkDir
  
  changeCursor()
  
  ttText := "
  (
    Imagecapture: Press and hold the [Alt]-key,
    then click on top-left of the text-area and
    hold down the [Alt]-key while moving the mouse,
    but do NOT drag the mouse.
    Release the [Alt]-key if the area is completly marked!
  )"
  
  tooltipFollowMouseOn(ttText)
   
  startGDI()
  
  Gui, overlay:New, -Caption +E0x80000 +LastFound +AlwaysOnTop +ToolWindow +OwnDialogs HWNDoverlayHWND
  Gui, overlay:Show, x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%
  
  hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
  hdc := CreateCompatibleDC()
  obm := SelectObject(hdc, hbm)
  theGraphics := Gdip_GraphicsFromHDC(hdc)
  Gdip_SetSmoothingMode(theGraphics, 4)
  
  theBrush := Gdip_BrushCreateSolid(0x660000ff)
  
  imgx := 0
  imgy := 0
  height := 0
  width := 0

  thePen := Gdip_CreatePen(0xffff0000, 3)
  
  KeyWait, LButton, D
  tooltipFollowMouseOff()
  mouseGetPos, x1, y1

  ;while getKeyState("LButton", "P"){
  downYKey := GetKeyState("Alt", "P")
  while (downYKey) {
    mouseGetPos, x2, y2
    Gdip_GraphicsClear(theGraphics)
    
    imgx := min(x1, x2)
    imgy := min(y1, y2)
    width := abs(x2 - x1)
    height := abs(y2 - y1)
    
    Gdip_FillRoundedRectangle(theGraphics, theBrush, imgx, imgy, width, height, 2)
    UpdateLayeredWindow(overlayHWND, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
    sleep, 100
    downYKey := GetKeyState("Alt", "P")
  }

  tooltipFollowMouseOff()
  resetCursor()
  
  Gui, overlay:Destroy
  
  Click, %x1% %y1%
  sleep, 500
  
  Image := Gdip_Bitmapfromscreen(imgx "|" imgy "|" width "|" height)
  
  Gdip_SetBitmapToClipboard(Image)
  Gdip_DisposeImage(Image)
  
  Gdip_DeleteBrush(theBrush)
  SelectObject(hdc, obm)
  DeleteObject(hbm)
  DeleteDC(hdc)
  Gdip_DeleteGraphics(theGraphics)
  StopGDI()
  
  return
}
;--------------------------- tooltipFollowMouseOn ---------------------------
tooltipFollowMouseOn(s){
  global tooltipText

  tooltipText := s
  settimer, tooltipFollowMouse, 1000

  return
}
;---------------------------- tooltipFollowMouse ----------------------------
tooltipFollowMouse(){
  global tooltipText
  
  mouseGetPos, mx, my
  mx := mx + 50
  tooltip, %tooltipText%, mx, my , 2

  return
}
;--------------------------- tooltipFollowMouseOff ---------------------------
tooltipFollowMouseOff(){

  settimer, tooltipFollowMouse, delete
  tooltip,,,, 2

  return
}
;----------------------------- imagePreviewShow -----------------------------
imagePreviewShow(){
  global filesArr, maxIndex
  
  maxIndex = 1

  fileList := ""
  filesArr := []
  f := "_savedclips\*.png"
  
  loop,Files,%f%,F
    fileList = %fileList%%A_LoopFileName%`n
    
  ; sort, fileList, R
  sort, fileList
  
  ; faster than strSplit()
  Loop, parse, fileList, `n
  {
      if A_LoopField =  ; Ignore the blank item at the end of the list.
          continue
          
      filesArr.push("_savedclips\" . A_LoopField)
      maxIndex++
  }

  createImageGui()

  return
}

;------------------------------ createImageGui ------------------------------
createImageGui(refreshOnly := false){
  global filesArr
  global pageIndexStart, page, imagesPerPage, imagesInColumn, imagesInRow, imagesGuiPageTop, imagesGuiPageBottom
  global clientWidth_imagesGui, clientHeight_imagesGui
  global sizeW, sizeH
  global Image1, Image2, Image3, Image4, Image5, Image6, Image7, Image8, Image9, Image10
  global Image11, Image12, Image13, Image14, Image15, Image16, Image17, Image18, Image19, Image20
  global Image21, Image22, Image23, Image24, Image25, Image26, Image27, Image28, Image29, Image30
  global Image31, Image32, Image33, Image34, Image35, Image36
  
  columnCounter := 0
  rowCounter := 0
  margin := 20
  padding := 20
  
  if (!refreshOnly){
    gui, imagesGui:Destroy

    gui, imagesGui:new,+OwnDialogs +LastFound +resize,Saved-clips preview

    gui, imagesGui:Add,button,xm ym Gback,<
    gui, imagesGui:Add,Text,x+m yp+0 VimagesGuiPageTop, %page%
    gui, imagesGui:Add,button,x+m yp+0 Gforward,>
    gui, imagesGui:Add,button,x+m yp+0 GimagePreviewClose, Close Saved-clips preview
    gui, imagesGui:Add,text,x+m yp+0, (Delete a clip: Hold down [Shift] + [Control] and click on the clip!)
    gui, imagesGui:Show,center Maximize
    gui, imagesGui:Hide
    
    sizeW := floor(clientWidth_imagesGui / imagesInColumn) - (imagesInColumn - 1) * padding
    sizeH := floor(clientHeight_imagesGui / imagesInRow) - (imagesInRow - 1) * padding - 2 * margin
    
    ; create dummy image
    startGDI()
    pBitmap := Gdip_CreateBitmap(sizeW, sizeH)
    G := Gdip_GraphicsFromImage(pBitmap)
    Gdip_SaveBitmapToFile(pBitmap, "dummy.png")
    DeleteObject(pBitmap)
    Gdip_DeleteGraphics(G)
    stopGDI()

    ; first row
    xPos := "xm" 
    yPos := ""

    loop, %imagesPerPage%
    {
      index := A_Index
      thePath := filesArr[pageIndexStart + index]

      gui, imagesGui:Add, Picture,w%sizeW% h%sizeH% %xPos% %yPos% VImage%index% Gdoit +Border,dummy.png
      
      columnCounter += 1

     if (columnCounter == imagesInColumn){
        columnCounter := 0
        xPos := "xm" 
        yPos := "yp+0"
        ; next column:
        gui, imagesGui:Add,Text, %xPos%, %A_Space%
      } else {
        ; not first row
        xPos := "xp+" . (sizeW + padding)
        yPos := "yp+0"
      }
    }
    
    gui, imagesGui:Add,button,xm Gback,<
    gui, imagesGui:Add,Text,x+m yp+0 VimagesGuiPageBottom, %page%
    gui, imagesGui:Add,button,x+m yp+0 Gforward,>
    gui, imagesGui:Add,button,x+m yp+0 GimagePreviewClose, Close Saved-clips preview
    gui, imagesGui:Add,text,x+m yp+0, (Hold down [Shift] + [Control] to delete Saved-clips!)
       
    gui, imagesGui:Show,center maximize
    
    ; fill with resized images
    startGDI()
    loop, %imagesPerPage%
    {
      index := A_Index
      thePath := filesArr[pageIndexStart + index]
      
      if (thePath == "" || !FileExist(thePath))
        thePath := "dummy.png"
      
      pBitmap := Gdip_CreateBitmapFromFile(thePath)
      Width := Gdip_GetImageWidth(pBitmap)
      Height := Gdip_GetImageHeight(pBitmap)
      
      if (Width > 0 && Height > 0) {
        resizeFactor := Min(sizeW/Width, sizeH/Height)

        PBitmapResized := Gdip_CreateBitmap(Round(Width * resizeFactor), Round(Height * resizeFactor))
        G := Gdip_GraphicsFromImage(pBitmapResized)
        Gdip_DrawImage(G, pBitmap, 0, 0, Round(Width * resizeFactor), Round(Height * resizeFactor), 0, 0, Width, Height)
           
        hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapResized)
         
        GuiControl,imagesGui:,Image%index%,% "HBITMAP:*" hCRBitmap

        DeleteObject(hCRBitmap)
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(PBitmapResized)
      }
      Gdip_DisposeImage(pBitmap)
    }
    stopGDI()
  } else {
    GuiControl,imagesGui:,imagesGuiPageTop, %page%
    GuiControl,imagesGui:,imagesGuiPageBottom, %page%
    
   ; GuiControl,imagesGui:,Image%index%,%thePath%
 
   ; fill with resized images
    sizeW := floor(clientWidth_imagesGui / imagesInColumn) - (imagesInColumn - 1) * padding - 2 * margin
    sizeH := floor(clientHeight_imagesGui / imagesInRow) - (imagesInRow - 1) * padding - 2 * margin
    
    startGDI()
    loop, %imagesPerPage%
    {
      index := A_Index
      thePath := filesArr[pageIndexStart + index]
      
      if (thePath == "" || !FileExist(thePath))
        thePath := "dummy.png"
      
      pBitmap := Gdip_CreateBitmapFromFile(thePath)
      Width := Gdip_GetImageWidth(pBitmap)
      Height := Gdip_GetImageHeight(pBitmap)
      
      if (Width > 0 && Height > 0) {
        resizeFactor := Min(sizeW/Width, sizeH/Height)
     
        PBitmapResized := Gdip_CreateBitmap(Round(Width * resizeFactor), Round(Height * resizeFactor))
        G := Gdip_GraphicsFromImage(pBitmapResized)
        Gdip_DrawImage(G, pBitmap, 0, 0, Round(Width * resizeFactor), Round(Height * resizeFactor), 0, 0, Width, Height)
           
        hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapResized)
         
        GuiControl,imagesGui:,Image%index%,% "HBITMAP:*" hCRBitmap

        DeleteObject(hCRBitmap)
        Gdip_DeleteGraphics(G)
        Gdip_DisposeImage(PBitmapResized)
      }
      Gdip_DisposeImage(pBitmap)
    }
    stopGDI()
    
    
  }
  
  return
}

;----------------------------- imagePreviewClose -----------------------------
imagePreviewClose(){

  gui, imagesGui:Destroy
  showWindowForced()

  return
}

;---------------------------------- forward ----------------------------------
forward(){
  global page, pageIndexStart, imagesPerPage
  global maxIndex, configFile
  
  page += 1
  pageIndexStart := imagesPerPage * (page - 1)
  pageIndexStart := Min(pageIndexStart,maxIndex)
  page := 1 + Round(pageIndexStart /  imagesPerPage)
  
  IniWrite, %page%, %configFile%, operation, page
  
  createImageGui(true)
  
  return
}

;----------------------------------- back -----------------------------------
back(){
  global page, pageIndexStart, imagesPerPage
  global configFile
  
  page -= 1
  pageIndexStart := imagesPerPage * (page - 1)
  page := Max(page,1) 
  pageIndexStart := Max(pageIndexStart,0)
  
  IniWrite, %page%, %configFile%, operation, page
  
  createImageGui(true)

  return
}

;----------------------------------- doit -----------------------------------
doit(){
  global InternalPreviewImage, filesArr, pageIndexStart, page

  if (A_GuiEvent = "normal"){
    thePath := filesArr[pageIndexStart + StrReplace(A_GuiControl,"Image","")]

    ;  Ctrl + Shift
    if (getKeyboardState() == 12){
      if (FileExist(thePath)){
        FileDelete,%thePath%
        createImageGui()
      }
    } else {
      ; do not self trigger!
      OnClipboardChange("OnClipboardChangeFunction",0)
      startGDI()
      pBitmap := Gdip_CreateBitmapFromFile(thePath)
      G := Gdip_GraphicsFromImage(pBitmap)
      Gdip_SetBitmapToClipboard(pBitmap)
      
      pCRBitmap := Gdip_CreateBitmapFromClipboard()
      hCRBitmap := Gdip_CreateHBITMAPFromBitmap(pCRBitmap)
      
      GuiControl,guiMain:,InternalPreviewImage,% "HBITMAP:*" hCRBitmap
      
      DeleteObject(hCRBitmap)
      Gdip_DisposeImage(pCRBitmap)
      Gdip_DisposeImage(pBitmap)
      Gdip_DeleteGraphics(G)
      stopGDI()
      OnClipboardChange("OnClipboardChangeFunction",1)
      
      showWindow()
      refreshGui()
    }
  }  
  
  return
}
;--------------------------------- tipTop ---------------------------------
tipTop(msg, t := 3000, n := 1){

  s := StrReplace(msg,"^",",")
  
  toolX := Floor(A_ScreenWidth / 2)
  toolY := 2

  ToolTip,%s%, toolX, toolY, n
  
  WinGetPos, X,Y,W,H, ahk_class tooltips_class32

  toolX := (A_ScreenWidth / 2) - W / 2
  
  ToolTip,%s%, toolX, toolY, n
  
  if (t > 0){
    tvalue := -1 * t
    SetTimer,tipTopClose,%tvalue%
  }
  
  return
}

;------------------------------ tipTopClose ------------------------------
tipTopClose(){
  
  Loop, 20
  {
    ToolTip,,,,%A_Index%
  }
  
  return
}
;----------------------------------------------------------------------------
; ahkCommon-ersatz:

;------------------------------------ eq ------------------------------------
eq(a, b) {
  if (InStr(a, b) && InStr(b, a))
    return 1
  return 0
}
;-------------------------------- showMessage --------------------------------
showMessage(hk1, hk2, part1 = 170, part2 = 320){
  global menuHotkey
  global exitHotkey

  SB_SetParts(part1, part2)
  if (hk1 != ""){
    SB_SetText(" " . hk1 , 1, 1)
  } else {
    SB_SetText(" " . "Hotkey: " . hotkeyToText(menuHotkey) , 1, 1)
  }
    
  if (hk2 != ""){
    SB_SetText(" " . hk2 , 2, 1)
  } else {
    SB_SetText(" " . "Exit-hotkey: " . hotkeyToText(exitHotkey) , 2, 1)
  }
  
  memory := "[" . GetProcessMemoryUsage() . " MB]      "
  SB_SetText("`t`t" . memory , 3, 2)

  return
}
;------------------------------- removeMessage -------------------------------
removeMessage(){
  global menuHotkey
  global exitHotkey

  showMessage("", "")

  return
}
;----------------------------- getKeyboardState -----------------------------
getKeyboardState(){
  r := 0
  if (getkeystate("Capslock","T"))
    r := r + 1
    
  if (getkeystate("Alt","P"))
    r := r + 2
    
  if (getkeystate("Ctrl","P"))
    r:= r + 4
    
  if (getkeystate("Shift","P"))
    r:= r + 8
    
  if (getkeystate("LWin","P"))
    r:= r + 16
    
  if (getkeystate("RWin","P"))
    r:= r + 16

  return r
}
;--------------------------- GetProcessMemoryUsage ---------------------------
GetProcessMemoryUsage() {
    PID := DllCall("GetCurrentProcessId")
    size := 440
    VarSetCapacity(pmcex,size,0)
    ret := ""
    
    hProcess := DllCall( "OpenProcess", UInt,0x400|0x0010,Int,0,Ptr,PID, Ptr )
    if (hProcess)
    {
        if (DllCall("psapi.dll\GetProcessMemoryInfo", Ptr, hProcess, Ptr, &pmcex, UInt,size))
            ret := Round(NumGet(pmcex, (A_PtrSize=8 ? "16" : "12"), "UInt") / 1024**2, 2)
        DllCall("CloseHandle", Ptr, hProcess)
    }
    return % ret
}

