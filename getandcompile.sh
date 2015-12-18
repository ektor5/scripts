#!/bin/bash
#
# getandcompile.sh 
#
# Ek5 @ 2015/12
#
##

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
Usage: $0 [orig_src] [dir_src]
Get orig tar package and debian from a dir, compiles and copy debs back 
EOF
}
usagee(){
  usage
  error "$1" "$2"
}

#enable errors
set -e

#tests
[[ -n $1 ]] || error "need orig archive!"
[[ -n $2 ]] || error "need source dir!"

#ORIG=/path/name_ver.orig.tar.gz
ORIG_SRC=$1
ORIG=${ORIG_SRC##*/}

DIR_SRC=$2

[[ -f $ORIG_SRC ]] || error "cannot find archive!"
[[ -d $DIR_SRC ]] || error "cannot find source dir!"

#copy it 
cp "$ORIG_SRC" . || error "cannot cp orig archive here"
#extract it
tar -xf "${ORIG}" 

ORIG_VER=${ORIG/_/-}
ORIG_DIR=${ORIG_VER%%.orig.tar.gz}

#copy debian dir 
cp -r "${DIR_SRC}/debian/" "$ORIG_DIR" 

pushd "$ORIG_DIR"

#build
debuild -uc -us 

popd 

#copy back
cp *.deb "$DIR_SRC/.."

ok
