@rem remove_clipboardresize_exe_link_in_autostartfolder.bat

@set app=clipboardresize

@cd %~dp0

@del /Y %userprofile%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\%app%.lnk



