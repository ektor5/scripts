#!/bin/bash

if [ $UID -ne 0 ]
   then
    echo root privileges needed
    exit 1
fi


systemctl start rpc-idmapd rpc-mountd

systemctl start dnsmasq

systemctl start tftpd.socket tftpd
