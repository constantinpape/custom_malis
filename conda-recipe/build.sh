# Platform-specific dylib extension
if [ $(uname) == "Darwin" ]; then
    export CC=clang
    export CXX=clang++
    export DYLIB="dylib"
else
    export CC=gcc
    export CXX=g++
    export DYLIB="so"
fi

##
## START THE BUILD
##

mkdir -p build
cd build

CXXFLAGS="${CXXFLAGS} -I${PREFIX}/include"
LDFLAGS="${LDFLAGS} -Wl,-rpath,${PREFIX}/lib -L${PREFIX}/lib"

if [ $(uname) == Darwin ]; then
    CXXFLAGS="$CXXFLAGS -stdlib=libc++"
fi

PY_VER=$(python -c "import sys; print('{}.{}'.format(*sys.version_info[:2]))")
PY_ABIFLAGS=$(python -c "import sys; print('' if sys.version_info.major == 2 else sys.abiflags)")
PY_ABI=${PY_VER}${PY_ABIFLAGS}

##
## Configure
##
cmake .. \
        -DCMAKE_C_COMPILER=${CC} \
        -DCMAKE_CXX_COMPILER=${CXX} \
        -DCMAKE_BUILD_TYPE=RELEASE \
        -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9\
        -DCMAKE_INSTALL_PREFIX=${PREFIX} \
        -DCMAKE_PREFIX_PATH=${PREFIX} \
\
        -DCMAKE_SHARED_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_EXE_LINKER_FLAGS="${LDFLAGS}" \
        -DCMAKE_CXX_FLAGS="${CXXFLAGS}" \
        -DCMAKE_CXX_FLAGS_RELEASE="${CXXFLAGS} -O3 -DNDEBUG" \
        -DCMAKE_CXX_FLAGS_DEBUG="${CXXFLAGS}" \
\
        -DBUILD_NIFTY_PYTHON=ON \
        -DPYTHON_EXECUTABLE=${PYTHON} \
        -DPYTHON_LIBRARY=${PREFIX}/lib/libpython${PY_ABI}.${DYLIB} \
        -DPYTHON_INCLUDE_DIR=${PREFIX}/include/python${PY_ABI} \
##

##
## Compile
##
make
#make test

##
## Install to prefix
cp -r ${SRC_DIR}/build/python/custom_mallis ${PREFIX}/lib/python${PY_VER}/site-packages/
