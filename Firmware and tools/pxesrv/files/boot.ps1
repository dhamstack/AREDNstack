#write-host "There are a total of $($args.count) arguments"
#for ( $i = 0; $i -lt $args.count; $i++ ) {
#    write-host "Argument  $i is $($args[$i])"
#} 
#http://@opt54/boot.ps1?@mac as secondary boot filename
write-host "#!ipxe"
write-host 'set boot-url http://${next-server}'
write-host "echo " $args[0]
#write-host "sleep 5"
write-host 'kernel ${boot-url}/wimboot'
write-host 'initrd ${boot-url}/bootmgr                     bootmgr'
write-host 'initrd ${boot-url}/boot/BCD                    BCD'
write-host 'initrd ${boot-url}/Boot/boot.sdi               boot.sdi'
write-host 'initrd ${boot-url}/sources/x64/boot.wim            boot.wim'
write-host "boot"

