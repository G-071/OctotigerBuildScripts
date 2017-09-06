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

cd ${basedir}/src
if [ ! -d hpx ] ; then
    git clone git@github.com:STEllAR-GROUP/hpx.git
    cd hpx
    # git checkout 1.0.0
    git checkout cuda_clang
    cd ..
fi
# cd hpx
# git pull
cd $basedir

mkdir -p $builddir/hpx
cd $builddir/hpx

if [ ${malloc} == "jemalloc" ] ; then
    alloc_opts="-DJEMALLOC_ROOT=${builddir}/contrib -DHPX_WITH_MALLOC=jemalloc"
else
    alloc_opts="-DTCMALLOC_ROOT=${builddir}/contrib -DHPX_WITH_MALLOC=tcmalloc"
fi

      # -DHPX_WITH_CXX14=ON
      # -DHPX_WITH_CUDA_ARCH=sm_61

cmake -DCMAKE_TOOLCHAIN_FILE=${hpxtoolchain}                                        \
      -DCMAKE_BUILD_TYPE=$buildtype                                                 \
      -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                            \
      -DHPX_WITH_THREAD_IDLE_RATES=ON                                               \
      -DHPX_WITH_DISABLED_SIGNAL_EXCEPTION_HANDLERS=ON                              \
      -DHPX_WITH_PARCELPORT_MPI=${HPX_ENABLE_MPI}                                   \
      -DHPX_WITH_PARCELPORT_MPI_MULTITHREADED=${HPX_ENABLE_MPI}                     \
      -DHPX_WITH_DATAPAR_VC=ON                                                      \
      -DHPX_WITH_DATAPAR_VC_NO_LIBRARY=ON                                           \
      -DHPX_WITH_CUDA=OFF                                                           \
      -DVc_ROOT=${builddir}/Vc                                                      \
      -DBOOST_ROOT=$BOOST_ROOT                                                      \
      ${alloc_opts}                                                                 \
      -DHWLOC_ROOT=${builddir}/contrib                                              \
      -DCMAKE_INSTALL_PREFIX=.                                                      \
      -DHPX_WITH_EXAMPLES=OFF                                                       \
      -DHPX_WITH_PARCELPORT_LIBFABRIC=OFF                                           \
      ${basedir}/src/hpx

make -j${PARALLEL_BUILD} core components VERBOSE=1
cd $basedir
