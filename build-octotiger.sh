#!/bin/bash
set -e
set -x

if [ -z ${basedir+x} ] ; then
    echo "basedir is not set. Please source sourceme.sh";
    kill -INT $$
fi

cd ${basedir}/src
if [ ! -d octotiger ] ; then
    git clone git@github.com:STEllAR-GROUP/octotiger.git
    cd octotiger
    git checkout double_loop_comp_int
    cd ..
fi
cd octotiger
git pull

mkdir -p $builddir/octotiger
cd $builddir/octotiger
export CXXFLAGS=${mycxxflags}
export CFLAGS=${mycflags}
export LDFLAGS=${myldflags}
cmake \
-DCMAKE_TOOLCHAIN_FILE=${hpxtoolchain} \
-DCMAKE_PREFIX_PATH=${builddir}/hpx \
-DHPX_WITH_MALLOC=${malloc} \
-DCMAKE_BUILD_TYPE=${buildtype} \
-DOCTOTIGER_WITH_SILO=OFF \
${basedir}/src/octotiger

make -j${PARALLEL_BUILD} VERBOSE=1

cd $basedir
