#!/bin/bash

if [[ $1 != '' ]];then
  BASEDIR=$1
elif [[ $POLARIS_DEPS_DIR != '' ]]; then
  BASEDIR=$POLARIS_DEPS_DIR
else
  BASEDIR=/opt/polarisdeps
fi
GCC_VER=$(./gcc_ver.sh gcc)
DEPSDIR=$BASEDIR/$GCC_VER
echo compiler version=$GCC_VER
mkdir -p $DEPSDIR

echo "Building in: $DEPSDIR"

LOGDIR=$DEPSDIR/builds
mkdir -p $LOGDIR

BUILD_ERROR=0
LOG4_STATUS=0
BOOST_STATUS=0
RAPIDJSON_STATUS=0
BUILD2_STATUS=0
ODB_COMPILER_STATUS=0
ODB_DEBUG_STATUS=0
ODB_RELEASE_STATUS=0
GTEST_STATUS=0

LOG4_LOG=$LOGDIR/log4cpp_build.log
rm -f $BOOST_LOG
./linux/build-log4cpp-1.1.3.sh $DEPSDIR > $LOG4_LOG 2>&1
if [ $? -ne 0 ]
then
  echo "Build of log4cpp 1.1.3  - FAIL"
  BUILD_ERROR=1
  LOG4_STATUS=1
else
  echo "Build of log4cpp 1.1.3 finished"
fi

BOOST_LOG=$LOGDIR/boost_build.log
rm -f $BOOST_LOG
./linux/build-boost-1.71.0.sh $DEPSDIR > $BOOST_LOG 2>&1
if [ $? -ne 0 ]
then
  echo "Build of Boost 1.71.0  - FAIL"
  BUILD_ERROR=1
  BOOST_STATUS=1
else
  echo "Build of Boost 1.71.0 finished"
fi

RAPIDJSON_LOG=$LOGDIR/rapidjson_build.log
rm -f $RAPIDJSON_LOG
./linux/build-rapidjson-1.1.0.sh $DEPSDIR &> $RAPIDJSON_LOG
if [ $? -ne 0 ]
then
  echo "Build of rapidjson 1.1.0  - FAIL"
  BUILD_ERROR=1
  RAPIDJSON_STATUS=1
else
  echo "Build of rapidjson 1.1.0 finished"
fi

BUILD2_LOG=$LOGDIR/build2_build.log
rm -f $BUILD2_LOG
./linux/build-build2.sh $DEPSDIR &> $BUILD2_LOG
if [ ${PIPESTATUS[0]} -ne 0 ]
then
  echo "Build of build2  - FAIL"
  BUILD_ERROR=1
  BUILD2_STATUS=1
else  
  echo "Build of build2 finished"
fi
export PATH=$PATH:$DEPSDIR/build2/bin

ODB_COMPILER_LOG=$LOGDIR/build_odb_compiler.log
rm -f $ODB_COMPILER_LOG
./linux/build-odb-compiler-bebop.sh $DEPSDIR &> $ODB_COMPILER_LOG
if [ ${PIPESTATUS[0]} -ne 0 ]
then
  echo "Build of odb 2.5.0 compiler  - FAIL"
  BUILD_ERROR=1
  ODB_COMPILER_STATUS=1
else
  echo "Build of odb 2.5.0 compiler finished"
fi

ODB_DEBUG_LOG=$LOGDIR/build_odb_debug.log
rm -f $ODB_DEBUG_LOG
./linux/build-odb-debug.sh $DEPSDIR &> $ODB_DEBUG_LOG
if [ ${PIPESTATUS[0]} -ne 0 ]
then
  echo "Build of odb 2.5.0 debug  - FAIL"
  BUILD_ERROR=1
  ODB_DEBUG_STATUS=1
else
  echo "Build of odb 2.5.0 debug finished"
fi

ODB_RELEASE_LOG=$LOGDIR/build_odb_release.log
rm -f $ODB_RELEASE_LOG
./linux/build-odb-release.sh $DEPSDIR &> $ODB_RELEASE_LOG
if [ ${PIPESTATUS[0]} -ne 0 ]
then
  echo "Build of odb 2.5.0 release  - FAIL"
  BUILD_ERROR=1
  ODB_RELEASE_STATUS=1
else
  echo "Build of odb 2.5.0 release finished"
fi


GTEST_LOG=$LOGDIR/gtest_build.log
rm -f $GTEST_LOG
./linux/build-gtest-1.7.0.sh $DEPSDIR &> $GTEST_LOG
if [ $? -ne 0 ]
then
  echo "Build of gtest 1.7.0  - FAIL"
  BUILD_ERROR=1
  GTEST_STATUS=1
else
  echo "Build of gtest 1.7.0 finished"
fi

if [ $LOG4_STATUS -ne 0 ]; then echo "Build of log4cpp 1.1.3  - FAIL"; else echo "log4cpp 1.1.3 build completed - SUCCESS"; fi
if [ $BOOST_STATUS -ne 0 ]; then echo "Build of Boost 1.71.0  - FAIL"; else echo "Boost 1.71.0 build completed - SUCCESS"; fi
if [ $RAPIDJSON_STATUS -ne 0 ]; then echo "Build of rapidjson 1.1.0  - FAIL"; else echo "Build of rapidjson 1.1.0 completed - SUCCESS"; fi
if [ $BUILD2_STATUS -ne 0 ]; then echo "Build of build2  - FAIL"; else echo "Build of build2 completed - SUCCESS"; fi
if [ $ODB_COMPILER_STATUS -ne 0 ]; then echo "Build of odb 2.5.0 compiler  - FAIL"; else echo "Build of odb 2.5.0 compiler completed - SUCCESS"; fi
if [ $ODB_DEBUG_STATUS -ne 0 ]; then echo "Build of odb 2.5.0 debug  - FAIL"; else echo "Build of odb 2.5.0 debug completed - SUCCESS"; fi
if [ $ODB_RELEASE_STATUS -ne 0 ]; then echo "Build of odb 2.5.0 release  - FAIL"; else echo "Build of odb 2.5.0 release competed - SUCCESS"; fi
if [ $GTEST_STATUS -ne 0 ]; then echo "Build of gtest 1.7.0  - FAIL"; else echo "Build of gtest 1.7.0 completed - SUCCESS"; fi

date
if [ $BUILD_ERROR -ne 0 ]
then
  echo "STATUS: FAIL"
  exit 1
fi
echo "STATUS: SUCCESS"
echo "Built in: $DEPSDIR"

