del %public%\desktop\*.lnk /f /q
rem cd %systemdrive%\extra
cscript createlnk.vbs %public%\desktop\cmd.lnk "%systemroot%\system32\cmd.exe"
cscript createlnk.vbs %public%\desktop\explorer++.lnk "%systemroot%\system32\explorer++.exe"
cscript createlnk.vbs %public%\desktop\penetwork.lnk "%systemroot%\system32\penetwork.exe"
