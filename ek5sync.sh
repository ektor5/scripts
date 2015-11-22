#!/bin/bash

# EK5 @ 2012 #
# Last modify 18-03-12 #

# ek5sync.sh #
# Syncronize films with my remote computer  

case $1 in

 "") 
  echo "Missing hostname!!!" 
  echo "Usage: $0 host category"
  echo "host can be \"lan\" or \"wifi\" or an IP address" 
  exit 
  ;;

 "lan")
  host=192.168.0.1
  ;;

 "wifi")
  host=192.168.1.2
  ;;

 *)
  host=$1
  ;;

esac

if [ -z $2 ] ; then

 echo "Missing category (Films,Roms,Music)" 
 exit

fi

what=$2

shift 		# Il comando shift in pratica fa questo: $2 -> $1, $3 -> $2, ecc...
shift


ORIG="/media/data/$what/"                 
DEST="root@$host:/media/data/$what/"

case $* in
 reverse*)
  shift
  ORIG="root@$host:/media/data/$what/"
  DEST="/media/data/$what/"
  ;;
esac

case $* in
 "") 
  spec="-rvhuL --progress --delete-after"
  ;;

 default*)
  shift
  spec="-rvhuL --progress --delete-after $* "      # $* sono tutti i parametri
  ;;

 add*)
  shift
  spec="-rvhL --progress --ignore-existing $*"
  ;;

 *)
  spec=$*
  ;;
esac
  

echo rsync $spec 			\
      $ORIG    \
      $DEST 	
 
rsync $spec 	                        \
      $ORIG                \
      $DEST
      