#!/bin/bash

sudo yum update
sudo yum group install "Development Tools"
sudo yum install centos-release-scl
sudo yum-config-manager --enable rhel-server-rhscl-7-rpms
sudo yum install devtoolset-8
sudo yum install devtoolset-8-gcc-plugin-devel
scl enable devtoolset-8 bash
source scl_source enable devtoolset-8

#install cmake - either download prebuilt or code and build it
#version 3.16 works well. 
#If you use qtcreator you just need to add it to the kit you want to use
#otherwise either put it in your path or create an alias
#https://cmake.org/download/
#https://github.com/Kitware/CMake/releases/download/v3.16.6/cmake-3.16.6-Linux-x86_64.sh
#
#https://download.qt.io/official_releases/qtcreator/
#Qt Creator 4.9.2 or newer

