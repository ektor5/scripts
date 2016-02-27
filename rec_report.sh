#!/bin/bash
# Photorec statistics
# Ek5 @02/2016

set -e

COMMAND=$1
DEST=$2
declare -A F D

print_iec() {
  numfmt --to=iec $@
}

total() {
  xargs du -b /dev/null | cut -f 1  |
  ( while read dim; do let S+=$dim ; done ; echo $S )
}

copy() {
  local DEST=$1
  mkdir -p "$DEST"
  xargs -I% cp -vrp % "$DEST"
}

move() {
  local DEST=$1
  mkdir -p "$DEST"
  xargs -I% mv % "$DEST"
}

compress() {
  #TODO
  tar -cvf $1 $DEST/$1
}

#search
F[DOCS]=$(find -type f \( -name '*.doc*' -o -name '*.odt' -o -name '*.xls*' -o -name '*.ppt*' \) )

F[PHOTOS]=$(find -type f \( -name '*.jpg' -o -name '*.png' \) -size +1M )

F[IMAGES_MINI]=$(find -type f \( -name '*.jpg' -o -name '*.png' \) ! -size +1M )

F[MUSIC]=$(find -type f \( -name '*.mp3' -o -name '*.mp4' \) -size +1M )

F[MUSIC_MINI]=$(find -type f \( -name '*.mp3' -o -name '*.mp4' \) ! -size +1M )

F[VIDEOS]=$(find -type f \( -name '*.mpg' -o -name '*.avi' \) -size +100M )

F[VIDEOS_MINI]=$(find -type f \( -name '*.mpg' -o -name '*.avi' \) \
  ! -size +100M -size +20M )

F[VIDEOS_MINIMINI]=$(find -type f \( -name '*.mpg' -o -name '*.avi' \) \
  ! -size +20M )

F[OTHERS]=$(find -type f ! \( -name '*.doc*' -o -name '*.odt' -o -name '*.xls*' -o \
  -name '*.ppt*' -o -name '*.jpg' -o -name '*.png' -o -name '*.mpg' -o -name '*.avi' -o -name '*.mp3' -o -name '*.mp4' \) )

echo xxxxxxxxxxxxxxxxxxxxxxxxxxxxx resume xxxxxxxxxxxxxxxxxxxxxxxxxxxxx

#print files
#for i in ${!F[*]} ; do echo -n "$i: " ; echo ${F[$i]} ; echo ; done
#compute du
for i in ${!F[*]} ; do D[$i]=$( echo ${F[$i]} | total ) ; done
#print du
for i in ${!D[*]} ; do echo -en "$i: "; print_iec ${D[$i]} ; done | sort | column -t

TOTAL=$( for i in ${D[*]} ; do let S+=$i ; done ; echo $S )

echo -en "\ntotal: "
print_iec $TOTAL

#check for command
if [[ -n $COMMAND ]]
then
  case $COMMAND in
    copy|compress|move) ;;
    *) echo "Command not valid"; exit 1 ;;
  esac
fi

# ask for action
if [[ -n $DEST ]]
then

  echo "$COMMAND all the files in $DEST?"
  read choice

  if [[ $choice == [yY]* ]]
  then
    #copy
    for i in ${!F[*]}
    do

      for i in ${F[$i]} ; do echo $i ; done | $COMMAND "$DEST/$i"

    done
  fi
fi
