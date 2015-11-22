#!/bin/bash
#
# Script to enable NAT forwarding 
#
# Ek5 @ 06/2013
#

WAN=${1:-"wlan0"}
LAN=${2:-"eth0"}
SOURCE=${3:-"192.168.0.0/24"}

FLUSH=0 

if [ $UID -ne 0 ]
then
  echo root privileges needed
  exit 1
fi

for i in "$WAN" "$LAN"
do
  if [ ! -d /sys/class/net/"$i" ]
  then
    echo $0: "$i" is not a valid interface >&2
    exit 1
  fi
done

if [ $FLUSH -ne 0 ] 
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
 
