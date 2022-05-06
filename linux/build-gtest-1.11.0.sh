#!/bin/bash

set -eu

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi

if [[ $2 != '' ]];then
  CXX=$2
else
  CXX=g++
fi

#Download and expand source files
GTESTTARFILE=$BASEDIR/release-1.11.0.tar.gz
GTESTDIR=$BASEDIR/googletest-release-1.11.0
if [ ! -f $GTESTTARFILE ];then
  wget -c 'https://github.com/google/googletest/archive/refs/tags/release-1.11.0.tar.gz' --directory-prefix=$BASEDIR
fi
if [ ! -d $GTESTDIR ];then
  tar xzf $GTESTTARFILE -C $BASEDIR
fi

BUILDDIR=$GTESTDIR/build
if [ ! -d $BUILDDIR ];then
  mkdir $BUILDDIR
fi
if [ ! -d $BUILDDIR/release ];then
  mkdir $BUILDDIR/release
fi
if [ ! -d $BUILDDIR/debug ];then
  mkdir $BUILDDIR/debug
fi

cd $BUILDDIR/release
cmake -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../..
make
cd $BUILDDIR/debug
cmake -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_BUILD_TYPE=Debug -G "Unix Makefiles" ../..
make
