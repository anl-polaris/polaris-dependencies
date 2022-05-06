#!/bin/bash

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi
echo BASEDIR=$BASEDIR

rm $BASEDIR/boost_1_60_0.tar.bz2
rm -r $BASEDIR/boost_1_60_0
rm $BASEDIR/v1.1.0.zip
rm -r $BASEDIR/rapidjson-1.1.0
rm $BASEDIR/release-1.7.0.zip
rm -r $BASEDIR/googletest-release-1.7.0
rm $BASEDIR/odb-2.4.0-x86_64-linux-gnu.tar.bz2
rm -r $BASEDIR/odb-2.4.0-x86_64-linux-gnu
rm $BASEDIR/libodb-sqlite-2.4.0.tar.bz2
rm -r $BASEDIR/libodb-sqlite-2.4.0
rm -r $BASEDIR/libodb-2.4.0
rm $BASEDIR/libodb-2.4.0.tar.bz2
rm -r $BASEDIR/sqlite-autoconf-3110100
rm $BASEDIR/sqlite-autoconf-3110100.tar.gz


