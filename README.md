# ClipboardResize ![Icon](https://github.com/jvr-ks/clipboardresize/blob/main/clipboardresize.png?raw=true)
(Windows only)  

#### Description
The purpose of the app is to reduce the size of a captured image inside the clipboard and possibly save it to a file.  
  
~~It and can be used as an interface to the Tesseract OCR also.~~  
(Please instead use simpletools -> [clipboardForce](https://github.com/jvr-ks/simpletools#clipboardForce) now!)  
  
After starting "clipboardresize.exe", it silently runs in the background looking for a new image in the clipboard.  

If the clipboard content is changed, the app is activated and runs the selected operations, i.e. resize, save etc. \*2)   
  
To copy the screen content (or a part of it) to the clipboard,  
use the Windows 10 builtin hotkeys:
  
Hotkey | Operation  
------------ | -------------  
**\[SHIFT] + \[Printscreen]** | capture the whole screen  
**\[ALT] + \[Printscreen]** | capture the active window only  
**\[CTRL] + \[WIN] + \[s]** | capture a selectable screen area  
**\[ALT] + \[z]** | an alias of the standard Windows capture a selectable screen area  
  
Or use the ClipboardResize hotkey:  
  
Hotkey | Operation  
------------ | ------------- 
**\[CTRL] +\[ALT] + \[z]** | the ClipboardResize capture hotkey  
  
The ClipboardResize capture hotkey operates likewise:  
if configfile section \[config] -&gt; winHotkeyAliasEnable=1 -&gt; as a simpler alias to \[SHIFT] + \[WIN] + \[S] or  
if configfile section \[config] -&gt; winHotkeyAliasEnable=0 -&gt; use the builtin "capture screen area"-operation. 
(the "builtin "capture screen area"-operation" is not usable at the moment!)  
  
If configfile section \[operation] -&gt; useActivator=1, the activator-button is shown, otherwise the ClipboardResize gui is activated.  
  
If anything is copied to the clipboard, the soundfile "clipboard.mp3" \*1) is played too.  
  
(The optional start-paramter "showwindow" forces ClipboardResize to show its gui-window after startup.)  
The download includes a batchfile "clipboardresize_startVisible.bat" to test it.  
  
To start the app with Windows, use the batchfile (powershell) "create_clipboardresize_exe_link_in_autostartfolder.bat", or  
take a look at the project [startdelayed](https://github.com/jvr-ks/startdelayed).  
   
\*1) Controlled by \[config] -&gt; clipboardBeepSound in the configfile.  
\*2) The app can only distinguish between data (possibly an image) and text.  

**configfile is "clipboardresize.ini".**  
  
#### Additional Hotkeys supplied by the app::
  
Hotkey | Action | Remarks 
------------ | ------------- | -------------    
**~~\[ALT] + \[y]~~** | OCR | *2) removed 
**\[SHIFT] + \[WIN] + \[z]** | show menu | operations are selectable  
**\[WIN] + \[ALT] + \[z]** | set resize-width and -height | settings are saved in configfile"  
**\[CTRL] + \[WIN] + \[z]** | capture fullscreen, reduced size | to clipboard + save as a file *1)  
**\[CTRL] + \[ALT] + \[WIN] + \[z]]** | kill the app (remove it from the memory) |  
**\[SHIFT] + \[ALT] + \[z]** | open filemanager | use the ".\_savedclips" folder  

*1) Image file (*.png format) is stored into the ".\_savedclips" folder,  
filenames are:  
"clpr_DATETIME_rs.png" (with extra "_rs"-ending are resized) and  
"clpr_DATETIME.png" (not resized),  
DATETIME is year_month_date_minute_second
of the current time.  
*2) Please instead use simpletools -> [clipboardForce](https://github.com/jvr-ks/simpletools#clipboardForce) now!
  
There is a preview (reduced size) in the center of the app-window too, 
and a \[FullSizeView clipboard] image button in the menu.
 
<a href="https://github.com/jvr-ks/clipboardresize/blob/main/assets/images/gt_kirche.png"><img src="https://github.com/jvr-ks/clipboardresize/blob/main/assets/images/clipboardresize_demo.png" align="left"></a>
<br clear="all" />
  
Using a hotkey to capture does **not** close an open clipboardresize window (but is faster than using a button)!  
Capture area: [SHIFT] + [WIN] + [s] hotkey is supplied by Windows 10, not by clipboardresize.  
Other Windows capture hotkeys: [WIN] + [PRINT] (capture whole screen) and [ALT] + [WIN] + [PRINT] (capture active window)  
do also **not** close an open clipboardresize window.  

#### ~~OCR integration~~  
removed  
  
#### Automode Checkboxes  
**Checkboxes only affect the hotkey operations, not operations that are triggered by a button press,**  
**besides the "Snipping Tool"-button!**  
  
* Auto-Resize  
  If not checked the captured image is not resized.  
  The original version of the captured image is written to the disk, if Auto-Save (fullsize) is checked.  
  
* Auto-Save  
  If not checked the resized version of the captured image is not written to the disk.  
  
* Auto-Save (fullsize)  
  If not checked the original version of the captured image is not written to the disk.  
  
* Activator-Button  
After an image is captured, instead of the Clipboardresize-Window the Activator button is shown only.  
  
* Autohide  
After an image is captured, the Clipboardresize-Window is closed after 2 seconds,  
which is usefull to capture multible images in series.  
Otherwise the Clipboardresize-Window is closed only, if it loses the focus (besides clicking the close-cross or killing the app).  
  
#### Download via Updater (preferred method)
Portable, run from any directory, but running from a subdirectory of the windows programm-directories   
(C:\Program Files, C:\Program Files (x86) etc.)  
requires admin-rights and is not recommended!  
**Directory must be writable by the app!**
 
Create a directory, example: "C:\jvrks\clipboardresize".  
  
Download Updater from Github to the previously created directory:  
**clipboardresize.exe** 64 bit Windows use:   
[updater.exe 64bit](https://github.com/jvr-ks/clipboardresize/raw/main/updater.exe)  
or  
**clipboardresize32.exe** 32 bit Windows use:  
[updater.exe 32bit](https://github.com/jvr-ks/clipboardresize/raw/main/updater32.exe)  
  
**Install only one version of clipboardresize!**  
Unpredictable behavior may occure otherwise.
  
[Updater viruscheck see Updater repository](https://github.com/jvr-ks/updater)   

* From time to time there are some false positiv virus detections
[Virusscan](#virusscan) at Virustotal see below.
  
**Be shure to use only one of the \*.exe at a time!**   
  
#### Auto-Resize, Auto-Save, Fullsize, Use-Activator, Auto-hide: 
As the name says ...  
* Use Activator-button  
If an image is captured to the clipboard the Activator-button is shown only (instead of the gui-window).  
* Auto-hide  
The app window hides itself after 4 seconds (hides only if focus lost otherwise).  
If capturing a series of images a approbiate setup is:  
Auto-Resize off/on, Auto-Save on, Use-Activator off, Auto-hide on.  
  
** An activated CAPSLOCK always prevents a resize!**  
Use it, to temporary disable any resize operation.  


#### Known issues / bugs  
  
Issue / Bug | Type | fixed in version  
------------ | ------------- | -------------  
Images are save again, if the "Snipping Tool" is closed | issue | 0.175
  
  
#### Requirements
* Windows 10 or later only.
* Directory must be writable.
  
#### Generated files in running directory:
* "\_savedclips\\*.png".
* "clipboardresize.ini"
  
#### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/main/hotkeys.md)  
Only "simple" hotkeys are allowed, i.e. a word character like "a", "b", "c" and preceding modifiers "#!^+~".  
  
#### Sourcecode
[GitHub URL](https://github.com/jvr-ks/clipboardrezise)  
  
[Autohotkey format](https://www.autohotkey.com)
  
#### Used Libraries:
Gdip\_All.ahk based on Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11

* Modified by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
* Modified by jvr 2020
* Supports: Basic, \_L ANSi, \_L Unicode x86 and \_L Unicode x64

#### Latest changes  

Version (&gt;=)| Change
------------ | -------------  
0.177 | OCR integration removed, integrated into "clipboardForce" (Simpletools) now
0.176 | Capture procedure enhanced to capture areas that would move otherwise (mouse drag not used anymore!)
0.174 | Open Filemanager Hotkey (\[SHIFT] + \[ALT] + \[z])
0.168 | Default ocr filenames changed to "_tmp.\*", ocr: using own area-capture mechanism, OCR-Hotkey default changed to Alt + y  
0.164 | A32 version removed
0.160 | clipboard text modification removed, an activated CAPSLOCK prevents a resize
0.156 | Removed Virtual-Key Codes from the configuration file, using autoconversion from "normal" keys now  
0.155 | Using Virtual-Key Codes in the configuration file
0.154 | OCR integration (changed) to Tesseract  
0.152 | Saved-clips preview latest clips are shown first  
0.145 | Saved-clips preview, Click on image to load it back to the clipboard  
0.144 | Gdip_All_patched.ahk removed variable-name duplicates  
0.143 | Updater integration  
0.142 | Gui "enhanced", Github repo default branch changed to "main"
0.141 | Autohide improved and enabled  
0.140 | On a Clipboard-change (content = image) a small activation-button "ClipboardResize" is shown at the top/center of the screen only (Dissappeares after 10 seconds)!  
  
  
#### License: GNU GENERAL PUBLIC LICENSE  
Please take a look at [license.txt](https://github.com/jvr-ks/clipboardresize/raw/main/license.txt)  
(Hold down the \[CTRL]-key to open the file in a new window/tab!)  
  
Copyright (c) 2024 J. v. Roos  

<a name="virusscan"></a>



##### Virusscan at Virustotal 
[Virusscan at Virustotal, clipboardresize.exe 64bit-exe, Check here](https://www.virustotal.com/gui/url/1977c19b29a79c3d996c6bf3c2c8e7a359a8ec556c715bc0076a4232678d9840/detection/u-1977c19b29a79c3d996c6bf3c2c8e7a359a8ec556c715bc0076a4232678d9840-1751190166
)  
[Virusscan at Virustotal, clipboardresize32.exe 32bit-exe, Check here](https://www.virustotal.com/gui/url/1d83a4583e13f6dd7dc1d9252f6ad23f0b4a1b2b6159b6ab1b96d0b9ffc59f0f/detection/u-1d83a4583e13f6dd7dc1d9252f6ad23f0b4a1b2b6159b6ab1b96d0b9ffc59f0f-1751190167
)  
