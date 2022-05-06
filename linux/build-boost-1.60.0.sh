#!/bin/bash

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi

# Download and expand source files
BOOSTTARFILE=$BASEDIR/boost_1_60_0.tar.bz2
BOOSTDIR=$BASEDIR/boost_1_60_0
[ ! -f $BOOSTTARFILE ] && wget -c 'http://sourceforge.net/projects/boost/files/boost/1.60.0/boost_1_60_0.tar.bz2' --directory-prefix=$BASEDIR
[ ! -d $BOOSTDIR ]     && tar xfj $BOOSTTARFILE -C $BASEDIR

# if you want to use boost libraries (as opposed to just headers)
# uncomment the commands here:
cd $BOOSTDIR
./bootstrap.sh
./b2 variant=release install --prefix=$BOOSTDIR
./b2 variant=debug install --prefix=$BOOSTDIR
