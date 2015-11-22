#!/bin/bash


IFS="" 

find * | while read file 

  do ffprobe $file -show_streams 2>&1 | grep codec_name=$1 > /dev/null && echo $file 

done 


