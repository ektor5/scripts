#!/bin/bash
#
# getandcompile.sh 
#
# Ek5 @ 2015/12
#
##

clean(){
  cd ~-0
  [[ ! -d $TMP ]] || rm -rf $TMP
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
Usage: $0 [orig_pkg] [debian_pkg] [dest]
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

ORIG=`basename "$ORIG_SRC"`

#tests
[[ -f $ORIG_SRC ]] || error "cannot find archive!"
[[ -d $DEB_SRC ]] || error "cannot find source dir!"

#create tmp dir
TMP=`mktemp -d`
if (( $? )) 
then error "Cannot create tmp dir"
fi

trap error INT KILL EXIT QUIT ABRT TERM

#copy orig 
cp "$ORIG_SRC" "$TMP" || error "cannot cp orig stuff"
cp -r "$DEB_SRC" "$TMP" || error "cannot cp deb stuff"

#go there
pushd "$TMP"

#extract it
tar -xf "${ORIG}" || error "cannot extract the orig"

ORIG_DIR=${ORIG%%.orig.tar.gz}
ORIG_NOR=${ORIG_DIR/_/-}
ORIG_VER=${ORIG_DIR##*_}

DEB=`basename "$DEB_SRC"`

#copy debian dir 
mv "${DEB}" "$ORIG_NOR/debian/" || 
  error "cannot cp debian dir to src. is the source dir name formatted well?"  

pushd "$ORIG_NOR"

#change version
echo "Change version, update revision or release? (v/i/r)"
read choice

case $choice in
  v) MOD="--newversion $ORIG_VER" ;;
  i) MOD="--increment 'Building release'" ;;
  r) MOD="--release" ;;
  *) error "Bad option" ;;
esac

dch -M $MOD || error

#build
debuild --no-lintian -uc -us || error

popd 
popd

#copy back
cp $TMP/*.deb           "$DEST" || error
cp $TMP/*.changes       "$DEST" || error
cp $TMP/*.build         "$DEST" || error
cp $TMP/*.dsc           "$DEST" || error
cp $TMP/*.debian.tar.gz "$DEST" || error

clean

ok
