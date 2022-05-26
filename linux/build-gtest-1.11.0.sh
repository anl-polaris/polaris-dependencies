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

# Default to g++ unless $2 is defined
CXX=g++
[[ ! -z ${2+x} ]] && CXX=$2

#Download and expand source files
GTESTTARFILE=$BASEDIR/release-1.11.0.tar.gz
GTESTDIR=$BASEDIR/googletest-release-1.11.0
BUILDDIR=$GTESTDIR/build
URL='https://github.com/google/googletest/archive/refs/tags/release-1.11.0.tar.gz'

[[ -f $GTESTTARFILE ]] || wget -c ${URL} --directory-prefix=$BASEDIR
[[ -d $GTESTDIR ]]     || tar xzf $GTESTTARFILE -C $BASEDIR

mkdir -p $BUILDDIR/{debug,release}

cd $BUILDDIR/release
cmake -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../..
make
cd $BUILDDIR/debug
cmake -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=Debug -G "Unix Makefiles" ../..
make
