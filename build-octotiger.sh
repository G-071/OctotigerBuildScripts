#!/bin/bash
set -e
set -x

if [ -z ${octotiger_source_me_sources} ] ; then
    source source-me.sh
fi

# if [ -z ${basedir+x} ] ; then
#     echo "basedir is not set. Please source sourceme.sh";
#     kill -INT $$
# fi

# if [[ `echo $HOSTNAME | grep daint` ]]; then
#     export CC=nvcc
#     export CXX=nvcc
# fi

cd ${basedir}/src
if [ ! -d octotiger ] ; then
    git clone git@github.com:STEllAR-GROUP/octotiger.git
    cd octotiger
    git checkout m2m_on_cuda
    cd ..
fi
cd octotiger
# git pull

mkdir -p $builddir/octotiger
cd $builddir/octotiger
export CXXFLAGS=${mycxxflags}
export CFLAGS=${mycflags}
export LDFLAGS=${myldflags}
# -DCMAKE_C_COMPILER=$CC \
    # -DCMAKE_CXX_COMPILER=$CXX \
    # -DCMAKE_TOOLCHAIN_FILE=${hpxtoolchain} \
cmake \
-DCMAKE_PREFIX_PATH=${builddir}/hpx \
-DHPX_WITH_MALLOC=${malloc} \
-DOCTOTIGER_WITH_CUDA=${OCTOTIGER_ENABLE_CUDA} \
-DCMAKE_BUILD_TYPE=${buildtype} \
-DOCTOTIGER_WITH_SILO=OFF \
${basedir}/src/octotiger

make -j${PARALLEL_BUILD} VERBOSE=1

cd $basedir
