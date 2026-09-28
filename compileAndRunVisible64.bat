@rem compileAndRunVisible64.bat

@echo off

@call clipboardresize.exe remove

@call "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in clipboardresize.ahk /out clipboardresize.exe /icon clipboardresize.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

@start clipboardresize.exe showwindow

@exit




