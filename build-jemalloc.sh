#!/bin/bash
set -e
set -x

if [ -z ${basedir+x} ] ; then
    echo "basedir is not set. Please source sourceme.sh";
    kill -INT $$
fi

cd ${basedir}/src
if [ ! -d jemalloc ] ; then
    git clone https://github.com/jemalloc/jemalloc.git
    cd jemalloc
    git checkout 4.5.0
    cd ..
fi

cd jemalloc
export CC=${mycc}
export CXX=${mycxx}
export CFLAGS=${mycflags}
export CXXFLAGS=${mycxxflags}

autoconf
if [ ! -d build ] ; then
    mkdir build
fi
cd build
../configure --prefix=${builddir}/contrib --enable-shared=no --enable-static=yes
make -j${PARALLEL_BUILD}
make install_include install_lib
cd $basedir
