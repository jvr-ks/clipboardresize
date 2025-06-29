@rem compile.bat

@echo off

@call clipboardresize.exe remove
@call clipboardresize32.exe remove


@"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in clipboardresize.ahk /out clipboardresize.exe /icon clipboardresize.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 64-bit.bin"

@"C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in clipboardresize.ahk /out clipboardresize32.exe /icon clipboardresize.ico /bin "C:\Program Files\AutoHotkey\Compiler\Unicode 32-bit.bin"

