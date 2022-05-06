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
SCRIPTSDIR=$(realpath $PWD/..)
TENSORFLOWSRC=$(realpath $BASEDIR/tensorflow_src)
TFLITEDIR=$BASEDIR/tflite-2.4.0

# rm -r $TENSORFLOWSRC
# rm -r $TFLITEDIR
[ ! -d $TENSORFLOWSRC ] && git clone https://github.com/tensorflow/tensorflow.git ${TENSORFLOWSRC}

cd $TENSORFLOWSRC
git checkout r2.5

echo cp $SCRIPTSDIR/tflite/tflite_cmake.txt $TENSORFLOWSRC/tensorflow/lite/CMakeLists.txt
cp $SCRIPTSDIR/tflite/tflite_cmake.txt $TENSORFLOWSRC/tensorflow/lite/CMakeLists.txt

mkdir -p $TFLITEDIR
cd $TFLITEDIR

cmake ../tensorflow_src/tensorflow/lite
cmake --build . -j

mkdir -p $TFLITEDIR/include
cp -r $TFLITEDIR/flatbuffers/include/flatbuffers/ $TFLITEDIR/include
cp -r $TFLITEDIR/abseil-cpp/absl/ $TFLITEDIR/include

mkdir -p $TFLITEDIR/include/tensorflow
cp -r $TENSORFLOWSRC/tensorflow/lite/ $TFLITEDIR/include/tensorflow

# rm -rf $TENSORFLOWSRC
