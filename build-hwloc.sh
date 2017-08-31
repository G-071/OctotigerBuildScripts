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
if [ ! -d hwloc-1.11.5 ] ; then
    if [ ! -f hwloc-1.11.5.tar.bz2 ] ; then
        wget https://www.open-mpi.org/software/hwloc/v1.11/downloads/hwloc-1.11.5.tar.bz2
    fi
    tar xvjf hwloc-1.11.5.tar.bz2
fi

mkdir -p hwloc-1.11.5/build
cd hwloc-1.11.5/build
../configure --prefix=${builddir}/contrib --disable-cairo --without-x --disable-libxml2 --disable-pci --disable-libnuma --enable-shared --enable-static --disable-libudev

make -j${PARALLEL_BUILD}
make install
cd $basedir
