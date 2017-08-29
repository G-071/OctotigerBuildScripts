#!/bin/bash
set -e
set -x

if [ -z ${basedir+x} ] ; then
    echo "basedir is not set. Please source sourceme.sh";
    kill -INT $$
fi

cd ${basedir}/src
if [ ! -d hpx ] ; then
    git clone git@github.com:STEllAR-GROUP/hpx.git
    cd hpx
    git checkout 1.0.0
    cd ..
fi
# cd hpx
# git pull
cd $basedir

mkdir -p $builddir/hpx
cd $builddir/hpx

if [ ${malloc} == "jemalloc" ] ; then
    alloc_opts="-DJEMALLOC_ROOT=${basedir}/${builddir}/contrib -DHPX_WITH_MALLOC=jemalloc"
else
    alloc_opts="-DTCMALLOC_ROOT=${basedir}/${builddir}/contrib -DHPX_WITH_MALLOC=tcmalloc"
fi

cmake -DCMAKE_TOOLCHAIN_FILE=${hpxtoolchain}                                        \
      -DCMAKE_BUILD_TYPE=$buildtype                                                 \
      -DHPX_WITH_THREAD_STACK_MMAP=ON                                               \
      -DHPX_WITH_THREAD_MANAGER_IDLE_BACKOFF=ON                                     \
      -DHPX_WITH_THREAD_BACKTRACE_ON_SUSPENSION=OFF                                 \
      -DHPX_WITH_THREAD_TARGET_ADDRESS=OFF                                          \
      -DHPX_WITH_THREAD_QUEUE_WAITTIME=OFF                                          \
      -DHPX_WITH_THREAD_IDLE_RATES=OFF                                              \
      -DHPX_WITH_THREAD_CUMULATIVE_COUNTS=OFF                                       \
      -DHPX_WITH_THREAD_STEALING_COUNTS=OFF                                         \
      -DHPX_WITH_THREAD_LOCAL_STORAGE=OFF                                           \
      -DHPX_WITH_SCHEDULER_LOCAL_STORAGE=OFF                                        \
      -DHPX_WITH_THREAD_GUARD_PAGE=OFF                                              \
      -DHPX_WITH_PARCELPORT_MPI=${HPX_ENABLE_MPI}                                   \
      -DHPX_WITH_PARCELPORT_MPI_MULTITHREADED=${HPX_ENABLE_MPI}                     \
      -DHPX_WITH_DATAPAR_VC=ON                                                      \
      -DHPX_WITH_DATAPAR_VC_NO_LIBRARY=ON                                           \
      -DCMAKE_SKIP_INSTALL_RPATH=ON                                                 \
      -DBoost_COMPILER="-gcc"                                                       \
      -DBOOST_ROOT=$BOOST_ROOT                                                      \
      -DVc_ROOT=${builddir}/Vc                                                      \
      ${alloc_opts}                                                                 \
      -DHWLOC_ROOT=${builddir}/contrib                                              \
      -DCMAKE_INSTALL_PREFIX=.                                                      \
      -DHPX_WITH_EXAMPLES=OFF                                                       \
      -DHPX_WITH_PARCELPORT_LIBFABRIC=OFF                                           \
      ${basedir}/src/hpx

make -j${PARALLEL_BUILD} core components VERBOSE=1
cd $basedir
