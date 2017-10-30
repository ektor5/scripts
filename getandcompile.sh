#!/bin/bash
#
# getandcompile.sh
#
# Ek5 @ 2015/12
#
#set -v

clean () {
  log "Nothing to clean..."
}

GREEN="\e[32m"
RED="\e[31m"
BOLD="\e[1m"
RST="\e[0m"

log() {
  # args: string
  local COLOR=${GREEN}${BOLD}  
  local MOD="-e"

  case $1 in
    err) COLOR=${RED}${BOLD}
      shift ;;
    pre) MOD+="n" 
      shift ;;
    fat) COLOR=${RED}${BOLD}
      shift ;;
    *) ;;
  esac

  echo $MOD "${COLOR}${*}${RST}"

}

error() {
  #error($E_TEXT,$E_CODE)

  local E_TEXT=$1
  local E_CODE=$2

  [[ -z $E_CODE ]] && E_CODE=1
  [[ -z $E_TEXT ]] || log err "$E_TEXT"

  log "Press enter to clean"
  read
  clean

  exit $E_CODE
}

ok() {
  #ok($OK_TEXT)
  local OK_TEXT=$1
  [[ -z $OK_TEXT ]] && OK_TEXT="Success!!"
  [[ -z $OK_TEXT ]] || log $OK_TEXT
  exit 0
}

usage(){
  cat << EOF
Usage: $0 orig_pkg debian_pkg dest [remote][:port]
Get orig tar package and debian from a dir, compiles and copy debs back

env switches:
LINTIAN=1	exec lintian after build
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

ORIG=$(basename "$ORIG_SRC")
ORIG_DIR=${ORIG%%.orig.tar.*}
ORIG_NOR=${ORIG_DIR/_/-}
ORIG_VER=${ORIG_DIR##*_}
 
#base implementation
cp_to () { cp $@ ; }
cp_from () { cp $@ ; }

#create tmp dir
if ! TMP=$(mktemp -d)
then error "Cannot create tmp dir"
fi

clean(){
  cd ~-0
  $REMOTE_CLEAN
  [[ ! -d $TMP ]] || rm -rf "$TMP"
}

trap error INT QUIT ABRT TERM

#tests
[[ -f $ORIG_SRC ]] || error "cannot find archive!"

if [[ -d $DEB_SRC ]]
then
  #make debian archive
  [[ -f $DEB_SRC/control ]] || error "control missing"
  [[ -f $DEB_SRC/changelog ]] || error "changelog missing"

  DEB_ZIP_SRC="$TMP/${ORIG_DIR}.debian.tar.gz"
  DEB_SRC_PATH=$(dirname "$DEB_SRC")
  DEB_SRC_NAME=$(basename "$DEB_SRC")

  tar -czf "$DEB_ZIP_SRC" \
    -C "$DEB_SRC_PATH" \
    --exclude '*~' --exclude "*.swp" --exclude "*.ex" \
    --transform "s/^$DEB_SRC_NAME/debian/" \
    "$DEB_SRC_NAME" || 
      error "Cannot make debian archive"

  DEB_SRC=$DEB_ZIP_SRC

elif [[ ! -f $DEB_SRC ]]
then
  error "Debian dir/archive not valid"
fi

DEB=$(basename "$DEB_SRC")

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
      local FILE="/`basename $1`"
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

    #disable clean
    remote trap - INT KILL EXIT QUIT ABRT TERM

    if (( $# ))
    then
      remote $@
    else
      cat | remote
    fi

    #close file descriptor, closes ssh connection
    exec 8>&-
  }

  remote_clean () {
    ssh $REM << LOL >> $REMOTE_LOG
    clean () {
      echo cleaning... ;
      cd ~-0 ;
      [[ ! -d $TMP ]] || rm -rf $TMP ;
    } ; clean ; exit 0
LOL
    exec 8>&-
  }

  #copy id to remote
  log pre "Copying SSH keys to remote... "
  ssh-copy-id $REM 2> /dev/null || error "cannot copy keys"
  log "Done!"

  TMP_FIFO="$(mktemp -u $TMP/fifo_tty-XXXXXX)"
  mkfifo $TMP_FIFO

  REMOTE="remote"
  REMOTE_INIT="remote_init"
  REMOTE_END="remote_end"
  REMOTE_LOG="`basename ${ORIG_SRC%%.orig*}`_remote.log"

  TMP=`ssh $REM -- mktemp -d`
  (( $? )) && error "Cannot create remote temp dir"

  remote_init(){

    #open connection
    ssh $REM < $TMP_FIFO > $REMOTE_LOG 2>&1 &
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
    remote echo "starting..."
    
    #enable remote_clean
    REMOTE_CLEAN="remote_clean"
  }

fi

#copy orig
log pre "Copying source files... "
cp_to "$ORIG_SRC" "$TMP" || error "cannot cp orig stuff"
cp_to "$DEB_SRC" "$TMP" || error "cannot cp deb stuff"
log "Done!"

#start remote connection
$REMOTE_INIT

#go there
$REMOTE pushd "$TMP"

#extract it
$REMOTE tar -xvf "${ORIG}" || error "cannot extract orig"
$REMOTE tar -xvf "${DEB}" -C ${ORIG_NOR} || error "cannot extract debian"

#copy debian dir
#$REMOTE mv "debian/" "$ORIG_NOR/debian/" ||
  #error "Cannot cp debian dir to src. is the source dir name formatted well?"

$REMOTE pushd "$ORIG_NOR"

#change version
echo "Change version, take from dir, increase revision or release? (v/d/i/r)"
read choice

case $choice in
  v) MOD="--newversion $ORIG_VER 'Building release'" ;;
  d) MOD="--fromdirname 'Building release'" ;;
  i) MOD="--increment --upstream 'Building release'" ;;
  r) MOD="--release 'Building release'" ;;
  *) error "Bad option" ;;
esac

log pre "Updating changelog... "
$REMOTE dch -M $MOD || error "debchange failed!"
$REMOTE cat "debian/changelog"
log "Done!"

#build
log pre "Building $ORIG_NOR... "
$REMOTE_END debuild --no-lintian -uc -us || error "Build failed!"

if (( REMOTE_PID ))
then
  wait $REMOTE_PID || error "Remote exited with $?" $?
fi
log "Done!"

#copy back
cp_from $TMP/*.deb           "$DEST" || error
cp_from $TMP/*.changes       "$DEST" || error
cp_from $TMP/*.build         "$DEST" || error
cp_from $TMP/*.dsc           "$DEST" || error
cp_from $TMP/*.debian.tar.*  "$DEST" || error

$REMOTE_CLEAN

clean

ok
