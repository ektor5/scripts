#!/bin/sh

LINK="$1"
i="$2"
MAX="$3"

while [ $i -lt $MAX ]
do
	if [ -e "./stream.dump.$i.ts" ]
	 then
	  echo "Err: already exist $i"
	else
 	 mplayer -dumpstream -dumpfile "stream.dump.$i.ts" -playlist "$LINK?start_seq=$i" 
	fi
	((i++))
done
