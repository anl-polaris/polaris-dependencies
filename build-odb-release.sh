#!/bin/bash
CXX=g++

gcc_ver=$(./gcc_ver.sh $CXX)
echo $gcc_ver

install_root=$1
install_path=$install_root/odb-2.5.0-release
lib_path=$install_path/lib
build_folder=build-odb-2.5.0-$gcc_ver-release
#BPKG_BIN=$install_root/build2/bin/bpkg
mkdir -p $install_path
cd $install_root
bpkg create -d $build_folder cc  --wipe \
  config.cxx=$CXX                 	\
  config.cc.coptions=-O3			\
  config.cxx.coptions=-std=c++17	\
  config.bin.rpath=$lib_path		\
  config.install.root=$install_path

cd $build_folder
bpkg add https://pkg.cppget.org/1/beta
bpkg fetch --trust-yes
bpkg build --yes libodb
bpkg build --yes libodb-sqlite
#bpkg build libodb-pgsql
#bpkg build libodb-mysql
bpkg install --all --recursive

