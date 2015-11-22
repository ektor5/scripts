#!/bin/bash
IFS="" # The  Internal  Field  Separator  that is used for word splitting
       #       after expansion and to split lines  into  words  with  the  read
       #       builtin  command.   The  default  value  is  ``<space><tab><new‐
       #       line>''.
       #       If IFS is unset, the parameters are  separated  by  spaces.   
       #       If IFS is null, the parameters are joined without intervening 
       #       separators.

#for file in `ls -b1 `
ls -1b | while read file
do
#VERBOSE 
#echo $file
#sleep 2
	cd $file
#pwd
#sleep 2
	mv * ..
#sleep 2
#	rmdir * 
#ls
#sleep 2
	cd ..
done
