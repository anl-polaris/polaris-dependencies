#!/bin/bash

set -o pipefail

main() {
  setup_variables "$@"
  build_dep log4cpp 1.1.3
  build_dep tflite 2.4.0
  build_dep glpk 4.65
  build_dep boost 1.71.0
  build_dep rapidjson 1.1.0

  # Build the build2 build tool and add it to the path (used to build odb)
  build_dep build2 0.14.0
  export PATH=$PATH:$DEPSDIR/build2/bin:$DEPSDIR/build2-build/${GCC_VER}/build2/bin

  build_dep odb compiler
  build_dep odb debug
  build_dep odb release

  build_dep gtest 1.7.0


  summarise
}

setup_variables() {
  if [[ $1 != '' ]]; then
    BASEDIR=$(realpath $1)
  elif [[ $POLARIS_DEPS_DIR != '' ]]; then
    BASEDIR=$(realpath $POLARIS_DEPS_DIR)
  else
    echo "Defaulting the dependency directory to /opt/polaris/deps"
    BASEDIR=/opt/polaris/deps
  fi
  if [[ $2 != '' ]];then
    CXX=$2
  else
    CXX=g++
  fi
  VERBOSE=0
  GCC_VER=$(./gcc_ver.sh $CXX)  
  DEPSDIR=$(realpath $BASEDIR/$GCC_VER)
  LOGDIR=$DEPSDIR/builds
  STATUSDIR=$DEPSDIR/build_status

  echo compiler version=$GCC_VER
  echo "Building in: $DEPSDIR"

  mkdir -p $DEPSDIR
  mkdir -p $LOGDIR
  mkdir -p $STATUSDIR
}

build_dep() {
  local dep=$1
  local version=$2
  local log_file=$LOGDIR/${dep}_build.log
  if [[ -f $STATUSDIR/${dep}-${version}-success ]]; then
    echo "Build of ${dep} ${version}  - SUCCESS (already built)"
    return 0
  fi

  if [[ ${VERBOSE} -gt 0 ]]; then
    ./build-${dep}-${version}.sh $DEPSDIR $CXX 2>&1 | tee -a ${log_file}
  else
    ./build-${dep}-${version}.sh $DEPSDIR $CXX &>> ${log_file}
  fi

  if [ $? -ne 0 ]
  then
    echo "Build of ${dep} ${version}  - FAIL"
    touch $STATUSDIR/${dep}-${version}-fail
  else
    echo "Build of ${dep} ${version}  - SUCCESS"
    rm -rf $STATUSDIR/${dep}-${version}-fail
    touch $STATUSDIR/${dep}-${version}-success
  fi
}


summarise() {
  echo
  echo "--------------------------"
  echo "        Summary"
  echo "--------------------------"
  echo
  ls $STATUSDIR | while read i; do
    local lib=$(echo $i | sed -e s/'\([a-z0-9]*\)-\([^-]*\)-.*'/"\1"/)
    local version=$(echo $i |  sed -e s/'\([a-z0-9]*\)-\([^-]*\)-.*'/"\2"/)
    local status=$(echo $i | sed -e s/'\([a-z0-9]*\)-\([^-]*\)-'/""/)
    if [[ "$status" == "success" ]]; then 
      symbol="✔"
    else
      symbol="✘"
    fi
    printf "%s  %12s (%8s)\n" $symbol $lib $versionD $status
  done
}

main "$@"
