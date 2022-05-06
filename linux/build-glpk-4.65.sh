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
BASEDIR=$(realpath $BASEDIR)
GLPKTARFILE=$BASEDIR/glpk-4.65.tar.gz
GLPKDIR=$BASEDIR/glpk-4.65

[[ -f $GLPKTARFILE ]] || wget -nv -c 'ftp://ftp.gnu.org/gnu/glpk/glpk-4.65.tar.gz' --directory-prefix=$BASEDIR
[[ -f ${GLPKDIR}/extraction.done ]] || (tar xf $GLPKTARFILE -C $BASEDIR && touch ${GLPKDIR}/extraction.done)

cd $GLPKDIR
./configure --prefix=$GLPKDIR
make --jobs=10
make install
exit 0
