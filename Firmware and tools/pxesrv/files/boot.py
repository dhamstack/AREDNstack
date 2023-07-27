#use sys.argv[1], sys.argv[2] etc to retrieve arguments
import sys
print( "#!ipxe")
if (len(sys.argv) > 1):print("echo " + sys.argv[1])
print( "set boot-url http://${dhcp-server}")
print( "kernel ${boot-url}/wimboot")
print( "initrd ${boot-url}/bootmgr                     bootmgr")
print( "initrd ${boot-url}/boot/BCD                    BCD")
print( "initrd ${boot-url}/Boot/boot.sdi               boot.sdi")
print( "initrd ${boot-url}/sources/boot.wim            boot.wim")
print( "boot")