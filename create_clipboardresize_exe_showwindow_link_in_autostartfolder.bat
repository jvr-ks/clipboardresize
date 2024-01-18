@rem create_clipboardresize_exe_showwindow_link_in_autostartfolder.bat
@rem parameter: hideGui

@set app=clipboardresize

@cd %~dp0

@powershell "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\%app%.lnk');$s.TargetPath='%~dp0\%app%.exe';$s.Arguments='showwindow';$s.Save()"



