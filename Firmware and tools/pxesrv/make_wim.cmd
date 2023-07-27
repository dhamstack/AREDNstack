set WINPE_ARCH=%processor_architecture%
set DEST=%~dp0
echo %winre%

for /f %%a in ('dir /b /a:h /S c:\recovery\*.wim') do set winre=%%a

echo %winre%
echo %dest%

if %PROCESSOR_ARCHITECTURE% == x86 (
xcopy %winre% %dest%files\sources\x86\ /h /y
attrib -H -S -R %dest%files\sources\x86\winre.wim
ren %dest%files\sources\x86\winre.wim boot.wim
) else (
xcopy %winre% %dest%files\sources\x64\ /h /y /e /r
attrib -H -S -R %dest%files\sources\x64\winre.wim
ren %dest%files\sources\x64\winre.wim boot.wim
)