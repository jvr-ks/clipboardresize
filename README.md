# Clipboardresize ![Icon](https://github.com/jvr-ks/clipboardresize/blob/master/clipboardresize.png?raw=true)
(Windows only)  
  
A.: The app reduces the size of a captured image in the clipboard.  
B.: If text is copied to the clipboard any format information is removed.  
C.: If a file (not an image) is copied to the clipboard, only the file-path information is copied to the clipboard!  
  
To disable B. and C. first activate the Capslock-key.  
In case of B. and C. the soundfile "clipboard.mp3" \*1) is played.  

After starting "clipboardresize.exe" it silently runs in the background looking for a new image in the clipboard.  
After detecting an image \*2) in the clipboard, the app window is shown.  

To start the app with an already open window use the start-paramter "showwindow".  

To start the app with Windows, use the batchfile (powershell) "create_clipboardresize_exe_link_in_autostartfolder.bat", or  
take a look at the project [startdelayed](https://github.com/jvr-ks/startdelayed).  
   
\*1) Controlled by \[config] -> clipboardBeepSound in the Config-file.
\*2) The app can only distinguish between data (possibly an image) and text.  
    
Use default windows (> 10) features hotkeys to capture:  
  
Hotkey | Operation
------------ | -------------
\[CTRL] + \[WIN] + \[s] | capture a selectable screen area
\[SHIFT] + \[Printscreen] | capture the whole screen
\[ALT] + \[Printscreen] | capture the active window only

#### Additional Hotkeys supplied by the app::
  
Hotkey | Action | Remarks
------------ | ------------- | -------------
**\[WIN] + \[Z]** | capture full screen, reduce size | to the clipboard
**\[SHIFT] + \[WIN] + \[z]** | show menu | operations are selectable
**\[WIN] + \[ALT] + \[Z]** | set resize-width and -height | settings are saved in the file "clipboardresize.ini"
**\[CTRL] + \[WIN] + \[z]** | capture fullscreen, reduced size | to clipboard + save as a file *1)
**\[CTRL+ALT+WIN+z]** | close app and clean memory |  
   
*1) Image file (*.png format) is stored into the ".\_savedclips" folder,  
filename ("screenshot\_ ...") is generated from date/time.
  
There is a preview (reduced size) in the center of the app-window too, 
and a \[FullSizeView clipboard] image button in the menu.
 

<a href="https://github.com/jvr-ks/clipboardresize/blob/master/clipboardresize_demo.png?raw=true?v24-11-2020"><img src="https://github.com/jvr-ks/clipboardresize/blob/master/clipboardresize_demo.png?raw=true?v24-11-2020" align="left"></a>  
##### OCR integration
To capture text (i.e. URLs etc.) that are pictures free capture2text can be "integrated".  
Download engine from (http://capture2text.sourceforge.net/#download)[http://capture2text.sourceforge.net/#download]  
and extract zip-file to a new sub-directory with the name "_Capture2Text".  
Default ocrHotkey is: \[WIN] + \[y], press the ocrHotkey then mark the text.  
Not rocket-science, but usable.  

##### Automode
If the "Automode" checkbox is checked, an automatic resize operation is executed in the background if a new clipboard-image is detected.  


##### Latest changes

Changed | Remarks
------------ | -------------
* Check if update is available during start removed, a button added instead 
* Default start is hidden now
* clipboardBeepSound -> controlled by \[config] -> clipboardBeepSound in the Config-file  
* Activate CAPSLOCK to disable text/file changes
* OCR integration, default hotkey is: \[WIN] + \[y]
* Plain text copy
* Automode
* filemanager | if leaved empty, the filemanager is used, which is set as the default in windows
* "showwindow" parameter removed | "hidewindow" parameter introduced instead
* "clipboardresize.exe" | 64-bit version (to switch versions remove app from memory first -> exit button)
* "clipboardresize32.exe" | 32-bit version
* Memory usage displayed \[...] | on the right side of the statusline
* hide app on window-minimize | or use the hide button

* "showwindow" parameter | changed from showMain
* helperscipt | create\_clipboardresize\_exe\_link\_in\_autostartfolder.bat
* Centerpreview | new!
* Gui switched from a context menu to a window | size is controlled by \[config] in the Config-file

###### Executable
* Download from github  
[clipboardresize.exe](https://github.com/jvr-ks/clipboardresize/raw/master/clipboardresize.exe)  
or  
[clipboardresize32.exe](https://github.com/jvr-ks/clipboardresize/raw/master/clipboardresize32.exe)  
or  
[clipboardresizeA32.exe](https://github.com/jvr-ks/clipboardresize/raw/master/clipboardresizeA32.exe)  
  
and the \[Configuration-file] (is generated if not existent)  
[clipboardresize.ini](https://github.com/jvr-ks/clipboardresize/raw/master/clipboardresize.ini)  
  
additional:  
  
[create_clipboardresize_exe_showwindow_link_in_autostartfolder.bat](https://github.com/jvr-ks/clipboardresize/raw/master/create_clipboardresize_exe_showwindow_link_in_autostartfolder.bat)  
  
[create_clipboardresize_exe_link_in_autostartfolder.bat]
(https://github.com/jvr-ks/clipboardresize/raw/master/create_clipboardresize_exe_link_in_autostartfolder.bat)  
  
[startVisible.bat](https://github.com/jvr-ks/clipboardresize/raw/master/startVisible.bat)  
  
[open_autostartfolder.bat](https://github.com/jvr-ks/clipboardresize/raw/master/open_autostartfolder.bat)  

 
Viruscheck (64 bit version only) see below.  
  
Clipboardresize is a portable app, nothing to install,  
but **running directory must be writable by the app!**
  
##### Source code: [Autohotkey format](https://www.autohotkey.com)
* clipboardresize.ahk
* files in "Lib"-sub-directory
  
###### Requirements
* Windows 10 or later only.
* Directory must be writable.
  
###### Generated files in running directory:
* "\_savedclips\\*.png".
* "clipboardresize.ini"
  
#### Hotkeys
[Overview of all default Hotkeys used by my Autohotkey "tools"](https://github.com/jvr-ks/cmdlinedev/blob/master/hotkeys.md)
  
###### Sourcecode
[GitHub URL](https://github.com/jvr-ks/clipboardrezise)
  
###### Used Libraries:
Gdip\_All.ahk based on Gdip standard library v1.45 by tic (Tariq Porter) 07/09/11

* Modified by Rseding91 using fincs 64 bit compatible Gdip library 5/1/2013
* Modified by jvr 2020
* Supports: Basic, \_L ANSi, \_L Unicode x86 and \_L Unicode x64
  
##### License: MIT
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sub license, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
  
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
  
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
  
Copyright (c) 2019/2020/2021 J. v. Roos


##### Viruscheck at Virustotal 
(64 bit version only) 
[Check here](https://www.virustotal.com/gui/url/5dbbb7c47db05f55abdca4239b241cc4cbc26dfa334be296e81675346b57b0ec/detection/u-5dbbb7c47db05f55abdca4239b241cc4cbc26dfa334be296e81675346b57b0ec-1626535046
)  
Use [CTRL] + Click to open in a new window! 
