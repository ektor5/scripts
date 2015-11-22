#!/bin/bash
#
# Script to enable NAT forwarding on hub
#
# Ek5 @ 06/2013
#

WAN=eth0

if [ $1 ]
then 
 WAN=$1
fi

LAN=eth0
SOURCE=192.168.0.0/24
FLUSH=1 

if [ $UID -ne 0 ]
 then
 echo root privileges needed
 exit 1
fi
 
if [ $FLUSH ] 
 then 
  iptables -t nat --flush
  iptables --flush 
fi

# FORWARD all packets from $LAN 
iptables -A FORWARD -i $LAN -j ACCEPT 

# MASK all packets with source in $SOURCE network on $WAN interface 
iptables -t nat -A POSTROUTING -s $SOURCE -o $WAN -j MASQUERADE

# ENABLE ip forwarding
if [ `cat /proc/sys/net/ipv4/ip_forward` -ne 1 ]
 then 
 echo 1 > /proc/sys/net/ipv4/ip_forward
fi

echo done
 
