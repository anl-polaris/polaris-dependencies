#!/bin/bash

set -eu

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi

CXX=g++

BUILD_DIR=$(realpath $BASEDIR/build2-build)

if [ -e $BASEDIR/build2/bin/bpkg ] 
then
	echo bpkg already built, skipping
	exit 0
fi

mkdir -p $BUILD_DIR
cd $BUILD_DIR

curl -sSfO https://download.build2.org/0.14.0/build2-install-0.14.0.sh
shasum -a 256 -b build2-install-0.14.0.sh
#  da35b527aac3427b449ca7525e97f81faba776ae7680179521963b90a21fba12

sh build2-install-0.14.0.sh --cxx $CXX --yes  --trust 70:64:FE:E4:E0:F3:60:F1:B4:51:E1:FA:12:5C:E0:B3:DB:DF:96:33:39:B9:2E:E5:C2:68:63:4C:A6:47:39:43 $BASEDIR/build2
