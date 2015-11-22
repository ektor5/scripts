#!/bin/sh

QUERY=$1 

#[ -z "$QUERY" ] && exit 1 
RESULT=''
SUM=0
if [ -n "$QUERY" ]  
  then RESULT=`pacman -Qsq $QUERY` || exit 1

  echo Pkgs found:
  cat <<< $RESULT 
  echo 

fi
pacman -Qi $RESULT | sed -n -e 's/Installed Size \:\ *\(.*\) \(.\)iB/\1\2/p'  | numfmt --from=si --to=none | 
  ( 
    while read i 
    do SUM=$( expr $SUM + $i ) 
    done ; echo Total for $QUERY: $( numfmt --to=si --from=none $SUM) 
  ) 
