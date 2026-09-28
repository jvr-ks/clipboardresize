@rem create_clipboardresize_exe_link_in_autostartfolder.bat
@rem default is start hidden now!

@set app=clipboardresize

@cd %~dp0

@powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\%app%.lnk');$s.TargetPath='%~dp0\%app%.exe';$s.Save()"



