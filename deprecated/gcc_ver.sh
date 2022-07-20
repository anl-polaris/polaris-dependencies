#!/bin/bash

cxx=g++
compiler_name=g++
if [ -n "$1" ]; then
  compiler_name=$(basename $1)
  cxx=$1
fi

#echo $cxx
#echo $compiler_name

compiler=""
version=""

case $compiler_name in
	clang|clang-*|clang++|clang++-*)
		compiler=$($cxx -v 2>&1 | head -n1 | cut -d" " -f1)
		version=$($cxx -v 2>&1 | head -n1 | cut -d" " -f3)
		;;
	gcc|g++|c++|gcc-*|g++-*|c++-*)
		compiler=$($cxx -v 2>&1 | tail -1 | cut -d" " -f1)
		version=$($cxx -v 2>&1 | tail -1 | cut -d" " -f3)
		;;
esac

echo $compiler-$version
