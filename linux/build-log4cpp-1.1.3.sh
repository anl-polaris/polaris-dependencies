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
DESTDIR=$BASEDIR/log4cpp/build
TARFILE=$DESTDIR/log4cpp-1.1.3.tar.gz
[ -f $TARFILE ]         || wget -c  --directory-prefix=$DESTDIR 'https://sourceforge.net/projects/log4cpp/files/latest/download/log4cpp-1.1.3.tar.gz'
[ -d $DESTDIR/log4cpp ] || tar xzf $TARFILE -C $DESTDIR

# configure and build in folder
INSTALL_DIR=$(realpath ${BASEDIR}/log4cpp)
cd $DESTDIR/log4cpp
./configure --prefix=${INSTALL_DIR}
make
# make check # test compilation fails on Ubuntu20.04+ - log4cpp hasn't been updated since 2017 so probably not needed 
make install
