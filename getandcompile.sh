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
if [[ -n ${REM} ]]
then
  #custom cp
  cp_to () {
    if [[ $1 == "-r" ]]
    then
      local OPT="$1"
      shift
      local FILE="/"
      scp "$OPT" "$1" "$REM:$2$FILE"
    else
      local FILE="/`basename $1`"
      scp "$1" "$REM:$2$FILE"
    fi

  }

  cp_from () {
   if [[ $1 =~ "-r" ]]
   then local OPT=$1
     shift
   fi
   scp $OPT $REM:$1 $2
  }

  TMP_FIFO="$(mktemp -u /tmp/fifo_tty-XXXXXX)"
  mkfifo $TMP_FIFO

  REMOTE="remote"
  REMOTE_END="remote_end"
  REMOTE_CLEAN="remote_clean"

  remote () {
    kill -0 $REMOTE_PID || error
    if (( $# ))
    then
      cat <<< "$@" > $TMP_FIFO ;
    else
      cat > $TMP_FIFO
    fi
  }

  remote_end () {
    if (( $# ))
    then
      remote $@
    else
      cat | remote
    fi

    #disable clean
    remote trap - INT KILL EXIT QUIT ABRT TERM
    exec 8>&-
  }

  remote_clean () {
    ssh $REM << LOL
    clean () {
      echo cleaning... ;
      cd ~-0 ;
      [[ ! -d $TMP ]] || rm -rf $TMP ;
    } ; clean ; exit 0
LOL
  }

  clean(){
    cd ~-0
    [[ ! -e $TMP_FIFO ]] || rm -rf $TMP_FIFO
  }

  #copy id to remote
  ssh-copy-id $REM || error "cannot copy keys"

  TMP=`ssh $REM -- mktemp -d`
  (( $? )) && error "Cannot create remote temp dir"

  REMOTE_INIT="remote_init"
  remote_init(){

    #open connection
    ssh $REM < $TMP_FIFO > get.log 2>&1 &
    REMOTE_PID=$!

    #keep fifo open
    exec 8> $TMP_FIFO

    remote set -evx
    remote << LOL
    clean () {
      echo cleaning... ;
      cd ~-0 ;
      [[ ! -d $TMP ]] || rm -rf $TMP ;
    } ;
LOL

    remote trap clean INT KILL EXIT QUIT ABRT TERM
    remote echo starting...
  }

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

trap error INT KILL QUIT ABRT TERM

#copy orig
cp_to "$ORIG_SRC" "$TMP" || error "cannot cp orig stuff"
cp_to -r "$DEB_SRC" "$TMP/" || error "cannot cp deb stuff"

#start remote connection
$REMOTE_INIT

#go there
$REMOTE pushd "$TMP"

#extract it
$REMOTE tar -xvf "${ORIG}" || error "cannot extract the orig"

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
  i) MOD="--increment --upstream 'Building release'" ;;
  r) MOD="--release" ;;
  *) error "Bad option" ;;
esac

$REMOTE dch -M $MOD || error

#build
$REMOTE_END debuild --no-lintian -uc -us || error

if (( REMOTE_PID ))
then
  wait $REMOTE_PID || error "remote exited with $?" $?
fi

#copy back
cp_from $TMP/*.deb           "$DEST" || error
cp_from $TMP/*.changes       "$DEST" || error
cp_from $TMP/*.build         "$DEST" || error
cp_from $TMP/*.dsc           "$DEST" || error
cp_from $TMP/*.debian.tar.gz "$DEST" || error

$REMOTE_CLEAN

clean

ok
