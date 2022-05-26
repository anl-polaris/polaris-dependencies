#!/bin/bash

set -eu

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi
BASEDIR=$(realpath ${BASEDIR})


CXX=g++
install_script_sum="f2e0795fda1bdc6b6ea4d2fc5917469725c20962bb1f6672c8d2462d76b3a7db *build2-install-0.14.0.sh"
cpp_get_shasum=70:64:FE:E4:E0:F3:60:F1:B4:51:E1:FA:12:5C:E0:B3:DB:DF:96:33:39:B9:2E:E5:C2:68:63:4C:A6:47:39:43
BUILD_DIR=$(realpath $BASEDIR/build2-build)
INSTALL_DIR=$(realpath $BASEDIR/build2)

if [ -e $INSTALL_DIR/bin/bpkg ]; then
	echo bpkg already built, skipping
	exit 0
fi

mkdir -p $BUILD_DIR
cd $BUILD_DIR

curl -sSfO https://download.build2.org/0.14.0/build2-install-0.14.0.sh
echo ${install_script_sum} | sha256sum -c

echo "BASEDIR      = ${BASEDIR}"
echo "BUILD_DIR    = ${BUILD_DIR}"
echo "INSTALL_DIR  = ${INSTALL_DIR}"
sh build2-install-0.14.0.sh --cxx $CXX \
                            --yes \
                            --trust ${cpp_get_shasum} \
                            $BASEDIR/build2
