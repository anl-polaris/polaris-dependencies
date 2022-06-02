#!/bin/bash

set -eu

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=$PWD
fi

# Download and expand source files
BASEDIR=$(realpath $BASEDIR)
BOOSTTARFILE=$BASEDIR/boost_1_71_0.tar.gz
BOOSTDIR=$BASEDIR/boost_1_71_0
[[ -f $BOOSTTARFILE ]] || \
  wget -nv -c 'https://boostorg.jfrog.io/artifactory/main/release/1.71.0/source/boost_1_71_0.tar.gz' --directory-prefix=$BASEDIR
[[ -f ${BOOSTDIR}/extraction.done ]] || (tar xf $BOOSTTARFILE -C $BASEDIR && touch ${BOOSTDIR}/extraction.done)

# if you want to use boost libraries (as opposed to just headers)
# uncomment the commands here:
#cd $BOOSTDIR
#./bootstrap.sh
#./b2 variant=release install --prefix=$BOOSTDIR
#./b2 variant=debug install --prefix=$BOOSTDIR