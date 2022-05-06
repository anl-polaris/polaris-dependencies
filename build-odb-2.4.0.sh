#!/bin/bash

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi

#Download and expand source files
ODBTARFILE=$BASEDIR/odb-2.4.0-x86_64-linux-gnu.tar.bz2
LIBODBTARFILE=$BASEDIR/libodb-2.4.0.tar.bz2
ODBSQLITEBTARFILE=$BASEDIR/libodb-sqlite-2.4.0.tar.bz2
SQLITETARFILE=$BASEDIR/sqlite-autoconf-3110100.tar.gz

ODBDIR=$BASEDIR/odb-2.4.0-x86_64-linux-gnu
LIBODBDIR=$BASEDIR/libodb-2.4.0
LIBSQLITEDIR=$BASEDIR/libodb-sqlite-2.4.0
SQLITE3DIR=$BASEDIR/sqlite-autoconf-3110100

if [ ! -f $ODBTARFILE ];then
  wget http://www.codesynthesis.com/download/odb/2.4/odb-2.4.0-x86_64-linux-gnu.tar.bz2 --directory-prefix=$BASEDIR
else
  echo $ODBTARFILE already exists
fi
if [ ! -d ODBDIR ];then
  tar xfj $ODBTARFILE -C $BASEDIR
fi

if [ ! -f $LIBODBTARFILE ];then
  wget http://www.codesynthesis.com/download/odb/2.4/libodb-2.4.0.tar.bz2 --directory-prefix=$BASEDIR
else
  echo $LIBODBTARFILE already exists
fi
if [ ! -d $LIBODBDIR ];then
  tar xfj $LIBODBTARFILE -C $BASEDIR
fi 

if [ ! -f $ODBSQLITEBTARFILE ];then
  wget http://www.codesynthesis.com/download/odb/2.4/libodb-sqlite-2.4.0.tar.bz2 --directory-prefix=$BASEDIR
else
  echo $ODBSQLITETARFILE already exists
fi
if [ ! -d $LIBSQLITEDIR ];then
  tar xfj $ODBSQLITEBTARFILE -C $BASEDIR
fi

if [ ! -f $SQLITETARFILE ];then
  wget https://www.sqlite.org/2016/sqlite-autoconf-3110100.tar.gz  --directory-prefix=$BASEDIR
else
  echo $SQLITETARFILE already exists
fi
if [ ! -d $SQLITE3DIR ];then
  tar xfz $SQLITETARFILE -C $BASEDIR
fi

mkdir $LIBODBDIR/build
mkdir $LIBODBDIR/build/debug
mkdir $LIBODBDIR/build/release
cd $LIBODBDIR/build/debug   && $LIBODBDIR/configure --prefix=$LIBODBDIR/debug  CPPFLAGS=-DDEBUG CXXFLAGS="-g -O0" && make && make install
cd $LIBODBDIR/build/release && $LIBODBDIR/configure --prefix=$LIBODBDIR/release CPPFLAGS=-DNDEBUG && make && make install

mkdir $SQLITE3DIR/build
mkdir $SQLITE3DIR/build/debug
mkdir $SQLITE3DIR/build/release
cd $SQLITE3DIR/build/debug   && $SQLITE3DIR/configure --prefix=$LIBODBDIR/debug/sqlite3  CPPFLAGS=-DDEBUG CXXFLAGS="-g -O0" && make && make install
cd $SQLITE3DIR/build/release && $SQLITE3DIR/configure --prefix=$LIBODBDIR/release/sqlite3 CPPFLAGS=-DNDEBUG && make && make install


mkdir $LIBSQLITEDIR/build
mkdir $LIBSQLITEDIR/build/debug
mkdir $LIBSQLITEDIR/build/release
cd $LIBSQLITEDIR/build/debug && $LIBSQLITEDIR/configure --prefix=$LIBODBDIR/debug/odb-sqlite  CPPFLAGS="-DDEBUG -I$LIBODBDIR/debug/include -I$LIBODBDIR/debug/sqlite3/include" CXXFLAGS="-g -O0" LDFLAGS="-L$LIBODBDIR/debug/lib -L$LIBODBDIR/debug/sqlite3/lib" && make && make install
cd $LIBSQLITEDIR/build/release && $LIBSQLITEDIR/configure --prefix=$LIBODBDIR/release/odb-sqlite CPPFLAGS="-DNDEBUG -I$LIBODBDIR/release/include -I$LIBODBDIR/release/sqlite3/include" LDFLAGS="-L$LIBODBDIR/release/lib -L$LIBODBDIR/release/sqlite3/lib" && make && make install
