#!/bin/bash

gcc_ver=$(./gcc_ver.sh)
echo $gcc_ver
mkdir -p $gcc_ver-compiler

install_root=$1
install_path=$install_root/odb-2.5.0-compiler
lib_path=$install_path/lib
build_folder=build-odb-2.5.0-$gcc_ver-compiler
mkdir -p $install_path
cd $install_root
bpkg create -d $build_folder cc  --wipe       \
  config.cxx=g++                  \
  config.cc.coptions=-O3          \
  config.cxx.coptions=-std=c++17	  \
  config.cxx.coptions=-I/blues/gpfs/software/centos7/spack-latest/opt/spack/linux-centos7-x86_64/gcc-6.5.0/gcc-8.2.0-xhxgy33/lib/gcc/x86_64-pc-linux-gnu/8.2.0/plugin/include	\
  config.bin.rpath=$lib_path \
  config.install.root=$install_path

cd $build_folder
bpkg build odb@https://pkg.cppget.org/1/beta --yes --trust-yes
bpkg test odb
bpkg install odb 

