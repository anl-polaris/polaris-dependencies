#!/bin/bash

set -eu

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi

#Download and expand source files
BASEDIR=$(realpath $BASEDIR)
TARFILE=$BASEDIR/v1.1.0.tar.gz
DESTDIR=$BASEDIR/rapidjson-1.1.0

[[ -f $TARFILE ]] || \
  wget -c 'https://github.com/miloyip/rapidjson/archive/v1.1.0.tar.gz' --directory-prefix=$BASEDIR
[[ -d $DESTDIR ]] || tar xzf $TARFILE -C $BASEDIR