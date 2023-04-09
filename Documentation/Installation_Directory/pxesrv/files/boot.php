<?php
//use $argv[1], $argv[2], etc to retrieve url parameters
echo "#!ipxe\n";
echo "echo ".$argv[1]."\n";
#echo "sleep 5\n";
echo "set boot-url http://${dhcp-server}\n";
echo "kernel ${boot-url}/wimboot\n";
echo "initrd ${boot-url}/bootmgr                     bootmgr\n";
echo "initrd ${boot-url}/boot/BCD                    BCD\n";
echo "initrd ${boot-url}/Boot/boot.sdi               boot.sdi\n";
echo "initrd ${boot-url}/sources/boot.wim            boot.wim\n";
echo "boot\n";
?>  