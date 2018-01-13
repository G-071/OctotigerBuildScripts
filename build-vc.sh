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
if [ ! -d Vc ] ; then
    # git clone git@github.com:VcDevel/Vc.git
    git clone git@github.com:STEllAR-GROUP/Vc.git
    cd Vc
    git checkout pfandedd_inlining_AVX512
    cd ..
fi
cd Vc
#git pull
cd ..

mkdir -p ${builddir}/Vc
cd ${builddir}/Vc
export CC=${mycc}
export CXX=${mycxx}
export FC=${myfc}

cmake \
-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
-DCMAKE_CXX_COMPILER=${mycxx} \
-DCMAKE_C_COMPILER=${mycc} \
-DCMAKE_CXX_FLAGS="${mycxxflags}" \
-DCMAKE_INSTALL_PREFIX=. \
${basedir}/src/Vc

cp compile_commands.json $basedir/src/Vc/compile_commands.json
rm CMakeCache.txt

#workaround to get compile commands...
cmake \
-DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
-DCMAKE_CXX_COMPILER=${mycxx} \
-DCMAKE_C_COMPILER=${mycc} \
-DCMAKE_CXX_FLAGS="${mycxxflags}" \
-DCMAKE_INSTALL_PREFIX=. \
-DBUILD_TESTING=OFF \
${basedir}/src/Vc

make -j${PARALLEL_BUILD}
make install
cd $basedir
