#!/bin/bash

## Dir stats
## EK5 @ 2014

if [[ $1 != "" ]] && [ -d $1 ] 
 then
	SOURCEDIR="$1"	
 else
	SOURCEDIR="."
fi

TOTAL=`du -sb "$SOURCEDIR" | cut -f 1` 
 
find "$SOURCEDIR" -type f |
 sed -n -e 's/.*\.\(.*\)$/\1/p' | 
 sort | 
 uniq --count | 
 sort -h | 
 tail -n 100 | 
 while read number file 
  do 
	echo "$file": "$number" files "$(du -sb "$SOURCEDIR" --exclude "*.$file" 2>/dev/null | 
  	cut -f 1 | 
	xargs -I% expr $TOTAL - % | 
  	numfmt --to=iec --suffix=B --format="%3f")"
 done
