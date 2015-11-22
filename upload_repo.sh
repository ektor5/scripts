#!/bin/bash

################################################################################
#
# Upload things to repo with rsync
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
usage: $0 [repo_dir] [proto://usr:pwd@url]
env var: DEBUG=[0-1]
EOF
}

usagee(){
  usage
  error "$1" "$2"
}

(( $# )) || usagee "Give me a repo to sync"

REPO="$1"
URL="$2"

[[ $REPO == "usage" ]] && usagee "" 0 
[[ $URL == "" ]] && usagee "Url unspecified" 1

[ -d "$REPO" ] || error "Repo dir not valid"
[ -d "$REPO/dists" ] || error "Dists dir not found"
[ -d "$REPO/pool" ] || error "Pool dir not fou:nd"

#rsync -av --progress --delete-after $POOL $URL -n
#rsync -av --progress --delete-after $DIST $URL -n

lftp -c "set ftp:list-options -a;
open $URL; 
set ssl:verify-certificate no

lcd $REPO/pool;
cd repository/pool;
mirror --reverse --delete --use-cache --verbose \
       --allow-chown --allow-suid --no-umask --parallel=2;

cd ../dists;
lcd ../dists;
mirror --reverse --delete --use-cache --verbose \
       --allow-chown --allow-suid --no-umask --parallel=2;
"

