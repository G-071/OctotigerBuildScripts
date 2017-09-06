#!/bin/bash

#use all available CPUs
export PARALLEL_BUILD=$((`lscpu -p=cpu | wc -l`-4))

export basedir=$PWD

if [[ `echo $HOSTNAME | grep tave` ]]; then
    echo "compiling for tave, doing additional setup";
    module load craype-mic-knl
    module switch PrgEnv-cray/6.0.3 PrgEnv-gnu
    module load CMake/3.8.1
    
    export myarch=${CRAY_CPU_TARGET}
    export hpxtoolchain=${basedir}/src/hpx/cmake/toolchains/CrayKNL.cmake
    
    # special flags for some library builds
    export mycflags="-fPIC -march=knl -ffast-math"
    export mycxxflags="-fPIC -march=knl -ffast-math"
    export myldflags="-fPIC"
    export HPX_ENABLE_MPI=ON
elif [[ `echo $HOSTNAME | grep daint` ]]; then
    echo "compiling for daint, doing additional setup";
    module switch PrgEnv-cray PrgEnv-gnu
    module load cudatoolkit
    module load CMake/3.8.1
    
    export myarch=${CRAY_CPU_TARGET}
    export hpxtoolchain=${basedir}/src/hpx/cmake/toolchains/CrayKNL.cmake
    
    # special flags for some library builds
    export mycflags="-fPIC -march=native -ffast-math"
    export mycxxflags="-fPIC -march=native -ffast-math"
    export myldflags="-fPIC"
    export HPX_ENABLE_MPI=ON    
else
    echo "other machine";
    export myarch=cpu
    export mycflags="-fPIC -march=native -ffast-math"
    export mycxxflags="-fPIC -march=native -ffast-math"
    export myldflags="-fPIC"
    export HPX_ENABLE_MPI=OFF
fi

if [[ ! -z $1 ]]; then
    if [[ ! ("$1" == "Release" || "$1" == "RelWithDebInfo" || "$1" == "Debug") ]]; then
    echo "build type invalid: valid are Release, RelWithDebInfo and Debug"
    kill -INT $$
    fi
    export buildtype=$1
else
    echo "no build type specified: specify either Release, RelWithDebInfo or Debug"
    kill -INT $$
    # export buildtype=Release
fi
echo "build type: $buildtype"
export malloc=jemalloc


export builddir=${basedir}/build-${myarch}-${buildtype}-${malloc}
export BOOST_ROOT=${builddir}/boost_1_63

export mycc=gcc
export mycxx=g++
export myfc=gfortran

mkdir -p src

export octotiger_source_me_sources=1

echo ""
echo "NB: "
echo "basedir is set to ${basedir}."
echo "  All paths are relative to that base."
echo "myarch is set to ${myarch}."
echo "  Build output will be in ${myarch}-build."
echo ""

