#!/bin/bash

set -eu

# ODB can only be built with gcc, not clang compatible
filedir=$(dirname "$0")

CXX=g++
gcc_ver=$($filedir/../gcc_ver.sh $CXX)

mkdir -p $gcc_ver-compiler

install_root=$1
install_path=$install_root/odb-2.5.0-compiler
lib_path=$install_path/lib
build_folder=build-odb-2.5.0-$gcc_ver-compiler
#BPKG_BIN=$install_root/build2/bin/bpkg
mkdir -p $install_path
cd $install_root
bpkg create -d $build_folder cc  --wipe       \
  config.cxx=$CXX                  		\
  config.cc.coptions=-O3          		\
  config.cxx.coptions=-std=c++17	  	\
  config.bin.rpath=$lib_path 			\
  config.install.root=$install_path

cd $build_folder
bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes
bpkg test odb
bpkg install odb 

