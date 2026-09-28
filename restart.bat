@rem restart.bat
@rem !file is overwritten by update process!

@cd %~dp0


@echo no news available!
@echo.
@echo Please press a key to restart clipboardresize (%1 bit)!
@echo.
@pause

@echo off

@set version=%1
@if [%1]==[64] set version=

@if [%2]==[noupdate] goto noupdate

@copy /Y clipboardresize.exe.tmp clipboardresize%version%.exe

:noupdate
@del clipboardresize.exe.tmp
@start clipboardresize%version%.exe showwindow

:end
@exit