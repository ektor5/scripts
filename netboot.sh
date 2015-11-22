#!/bin/bash

mount /dev/mapper/volGroup2-eewiki14_04 "/home/ektor-5/udoo/netboot/eewiki14_04"
sleep 1
exportfs -avf

systemctl restart nfs-server dnsmasq
systemctl stop netctl-ifplugd@eth0 
netctl start ethernet-static

/home/ektor-5/scripts/router.sh


