#!/bin/sh

echo ""
echo "Start pinging $1 !!!" 
echo ""
ping $1 -w 2

while [ $? != 0  ]

do 
 echo "Pinging $1 ... Now the IP is:"
 ping $1 -w 2 | grep -oP --color=never  "(\d*\.\d*\.\d*\.\d*)"
 ping $1 -w 2 > /dev/null
done 

echo "Now is up!!! At "`date`" !!!" 
echo ""
echo "Starting Firefox..."
echo ""

firefox $1:8000 > /dev/null
