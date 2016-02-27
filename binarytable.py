#!/bin/python
# 
# Simple truth table generator
# ek5 @ 02/2016
#

import sys
try:
    last=int(sys.argv[1])
except:
    print("Need a number!");
    quit(0);

length=len(bin(last-1))-2

for i in range(0,last):
    print(i,end="")
    print(" \t",end="")
    print(bin(i).split("b")[1].zfill(length))

