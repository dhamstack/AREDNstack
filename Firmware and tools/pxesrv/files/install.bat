ping -n 5 127.0.0.1 > NUL
rem probably win7 only and useful if you pushed a sanhook command
net use z: \\192.168.1.248\usbshare2 /user:erwan
x:\extra\clonedisk\vmount-win64 attachvhd "z:\iso\Win10\Win10_1903_V1_English_x64.iso"
pause