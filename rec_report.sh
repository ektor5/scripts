#!/bin/bash
# Photorec statistics
# Ek5 @02/2016

DEST=$1

print_iec() { 
  numfmt --to=iec $@
}

total() {
  xargs du -b /dev/null | cut -f 1  | 
  ( while read dim; do let S+=$dim ; done ; echo $S ) 

  #  mkdir $DEST/$1
  # xargs -I% cp -vrp % $DEST/$1
}

copy() {
  #xargs du -b /dev/null | cut -f 1  | 
  #( while read dim; do let S+=$dim ; done ; echo $S ) 

  mkdir $DEST/$1
  xargs -I% cp -vrp % $DEST/$1
}

du -h
declare -A F D

#search
F[DOCS]=$(find -type f \( -name '*.doc*' -o -name '*.odt' -o -name '*.xls*' -o -name '*.ppt*' \) )

F[PHOTOS]=$(find -type f \( -name '*.jpg' -o -name '*.png' \) -size +1M )

F[IMAGES_MINI]=$(find -type f \( -name '*.jpg' -o -name '*.png' \) ! -size +1M )

F[MUSIC]=$(find -type f \( -name '*.mp3' -o -name '*.mp4' \) -size +1M )

F[MUSIC_MINI]=$(find -type f \( -name '*.mp3' -o -name '*.mp4' \) ! -size +1M )

F[VIDEOS]=$(find -type f \( -name '*.mpg' -o -name '*.avi' \) -size +100M )

F[VIDEOS_MINI]=$(find -type f \( -name '*.mpg' -o -name '*.avi' \) \
  ! -size +100M -size +20M )

F[VIDEOS_MICRO]=$(find -type f \( -name '*.mpg' -o -name '*.avi' \) \
  ! -size +20M )

F[OTHERS]=$(find -type f ! \( -name '*.doc*' -o -name '*.odt' -o -name '*.xls*' -o \
  -name '*.ppt*' -o -name '*.jpg' -o -name '*.png' -o -name '*.mpg' -o -name '*.avi' -o -name '*.mp3' -o -name '*.mp4' \) )

echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxx resume xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

#print files
for i in ${!F[*]} ; do echo -n "$i: " ; echo ${F[$i]} ; echo ; done 
#compute du
for i in ${!F[*]} ; do D[$i]=$( echo ${F[$i]} | total ) ; done 
#print du
for i in ${!D[*]} ; do echo -en "$i: "; print_iec ${D[$i]} ; done | sort | column -t

TOTAL=$( for i in ${D[*]} ; do let S+=$i ; done ; echo $S )

echo -en "\ntotal: "
print_iec $TOTAL

if [[ -n $DEST ]] 
then
  [[ ! -d $DEST ]] && echo "error: dir not valid" && exit 1

  echo "copy all the files in $DEST?" 
  read choice

  if [[ $choice == [yY] ]]
  then 
    for i in ${!F[*]} ; do mkdir "$DEST/$i" || exit 1 ; cp -v ${F[$i]} "$DEST/$i" ; done 
  fi
fi
