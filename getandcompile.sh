#!/bin/bash
#
# getandcompile.sh 
#
# Ek5 @ 2015/12
#
##
set -v

clean () {
  echo Nothing to clean...
}

error() {
  #error($E_TEXT,$E_CODE)

  clean

  local E_TEXT=$1
  local E_CODE=$2

  [[ -z $E_CODE ]] && E_CODE=1
  [[ -z $E_TEXT ]] || echo $E_TEXT

  echo "Press enter to clean"
  read
  clean

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
Usage: $0 [orig_pkg] [debian_pkg] [dest] [remote]
Get orig tar package and debian from a dir, compiles and copy debs back 
EOF
}

usagee(){
  usage
  error "$1" "$2"
}

###
#START
###

#enable errors
set -e


#ORIG=/path/name_ver.orig.tar.gz
ORIG_SRC=$1
DEB_SRC=$2
DEST=${3:-.}
REM=${4}

ORIG=`basename "$ORIG_SRC"`

#tests
[[ -f $ORIG_SRC ]] || error "cannot find archive!"
[[ -d $DEB_SRC ]] || error "cannot find source dir!"

unset REMOTE 

#remote implementation
if (( ${REM} ))
then
  #custom cp 
  cp_to () { 
    if [[ $1 =~ "-r" ]] 
    then local OPT=$1 
      shift
    fi
    scp $OPT $1 $REM:/$2 
  }

  cp_from () { 
   if [[ $1 =~ "-r" ]] 
   then local OPT=$1 
     shift
   fi
   scp $OPT $REM:/$1 $2 
  } 

  TMP_FIFO=`mktemp`

  REMOTE="remote"
  remote () { 
    if (( $# )) 
    then
      cat <<< "$@" > $TMP_FIFO ; 
    else 
      cat > $TMP_FIFO 
    fi
  }

  #copy id to remote
  ssh-copy-id $REM || error "cannot copy keys"

  TMP=`ssh $REM mktemp -d`
  (( $? )) && error "Cannot create remote temp dir"

  LOCAL_PID=$$

  ( ssh $REM < $TMP_FIFO || error ) &

  REMOTE_PID=$!

  remote set -e
  remote << LOL
clean(){
  cd ~-0
  [[ ! -d $TMP ]] || rm -rf $TMP
}
LOL
  remote trap clean INT KILL EXIT QUIT ABRT TERM

else
  cp_to () { cp $@ ; }
  cp_from () { cp $@ ; }

  #create tmp dir
  TMP=`mktemp -d`
  if (( $? )) 
  then error "Cannot create tmp dir"
  fi

  clean(){
    cd ~-0
    [[ ! -d $TMP ]] || rm -rf $TMP
  }

fi

trap error INT KILL EXIT QUIT ABRT TERM

#copy orig 
cp_to "$ORIG_SRC" "$TMP" || error "cannot cp orig stuff"
cp_to -r "$DEB_SRC" "$TMP" || error "cannot cp deb stuff"

#go there
$REMOTE pushd "$TMP"

#extract it
$REMOTE tar -xf "${ORIG}" || error "cannot extract the orig"

ORIG_DIR=${ORIG%%.orig.tar.gz}
ORIG_NOR=${ORIG_DIR/_/-}
ORIG_VER=${ORIG_DIR##*_}

DEB=`basename "$DEB_SRC"`

#copy debian dir 
$REMOTE mv "${DEB}" "$ORIG_NOR/debian/" || 
  error "cannot cp debian dir to src. is the source dir name formatted well?"  

$REMOTE pushd "$ORIG_NOR"

#change version
echo "Change version, update revision or release? (v/i/r)"
read choice

case $choice in
  v) MOD="--newversion $ORIG_VER" ;;
  i) MOD="--increment 'Building release'" ;;
  r) MOD="--release" ;;
  *) error "Bad option" ;;
esac

$REMOTE dch -M $MOD || error

#build
$REMOTE debuild --no-lintian -uc -us || error

$REMOTE popd 
$REMOTE popd

#copy back
cp_from $TMP/*.deb           "$DEST" || error
cp_from $TMP/*.changes       "$DEST" || error
cp_from $TMP/*.build         "$DEST" || error
cp_from $TMP/*.dsc           "$DEST" || error
cp_from $TMP/*.debian.tar.gz "$DEST" || error

clean

ok
