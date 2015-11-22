#!/bin/bash

################################################################################
#
# Simple search and add deb and dsc script to reprepro repo
#
# Ek5 @ 2015/09
#
################################################################################

error() {
  #error($E_TEXT,$E_CODE)

  local E_TEXT=$1
  local E_CODE=$2
  
  [[ -z $E_CODE ]] && E_CODE=1
  [[ -z $E_TEXT ]] || echo $E_TEXT
  exit $E_CODE
}

ok() {
  #ok($OK_TEXT)
  local OK_TEXT=$1
  [[ -z $OK_TEXT ]] && OK_TEXT="Success!!"
  [[ -z $OK_TEXT ]] || echo $OK_TEXT 
  exit 0
}

usage(){
  cat << EOF
usage: $0 search_dir [repo_dir]
env var: DEBUG=[0-1]
EOF
}

usagee(){
  usage 
  error "$1"
}

[ -n "$1" ] || usagee "Search directory not provided"
DIRECTORY="$1"
[ -d "$DIRECTORY" ] || error "Search directory not valid"

shift

[ -n "$1" ] || usagee "Repo directory not provided"
REPODIR="$1"
[ -d "$REPODIR" ] || error "Repo directory not valid"

shift

[ -n "$1" ] && usagee "too many arguments" 


REPO=`reprepro -b . list udoobuntu | cut -f2 -d " "` 
(( $? )) && exit 1 

for i in `find "$DIRECTORY" -name *.deb` 
do 
	declare -a PACKAGES
	NAMEPACK=`echo "$i" | sed -e 's/.*\/\(.*\)_.*_.*.deb/\1/'`
	(( $DEBUG )) && echo searching deb: $NAMEPACK
	echo "$REPO" | grep -q "$NAMEPACK" 
	(( $? )) && PACKAGES+=( "$i" )
done

if [ -n "$PACKAGES" ] 
then	
	for i in ${PACKAGES[*]} ; do echo $i ; done
	echo -n 'Do you want to include this/those deb? '
	read CHOICE
	case "$CHOICE" in
		[yY]) reprepro -b . includedeb udoobuntu ${PACKAGES[*]} ;;
		*) exit 1 ;;
	esac
else
	echo "no deb found..."
fi

for i in `find "$DIRECTORY" -name *.dsc` 
do
	NAMEPACK=`echo "$i" | sed -e 's/.*\/\(.*\)_.*.dsc/\1/'`
	(( $DEBUG )) && echo searching dsc: $NAMEPACK
	echo "$REPO" | grep -q "$NAMEPACK" 
	(( $? )) && SOURCE="$i" 

	[[ -n $SOURCE ]] && 
		reprepro -b . includedsc udoobuntu $SOURCE && 
			SUCCESS=1
	unset SOURCE
done  

(( $SUCCESS )) || echo -e "no dsc found..."
