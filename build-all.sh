#!/bin/bash
set -e
set -x

source source-me.sh

./build-jemalloc.sh
./build-hwloc.sh
./build-boost.sh

./build-vc.sh
./build-hpx.sh
./build-octotiger.sh
