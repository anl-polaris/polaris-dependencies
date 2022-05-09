#!/bin/bash

set -eu

if [[ $1 != '' ]];then
  DEPSDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  DEPSDIR=$POLARIS_DEPS_DIR
else
  DEPSDIR=$PWD
fi

cd $(dirname "$0")

./build-build2-0.14.0.sh $DEPSDIR
export "PATH=$DEPSDIR/build2/bin:$PATH"

./build-odb-compiler.sh $DEPSDIR
./build-odb-debug.sh $DEPSDIR
./build-odb-release.sh $DEPSDIR
