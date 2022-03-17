#!/bin/bash

WORK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
THIRD_LIB="${WORK_DIR}"
THIRD_SRC="${WORK_DIR}/third-src"

mkdir -p ${THIRD_LIB}
mkdir -p ${THIRD_SRC}

function git_download()
{
  local url="${1}"
  local name="${2}"
  local version="${3}"
  local cur_dir="$(pwd)"

  mkdir -p ${THIRD_SRC} && cd ${THIRD_SRC}
  if [ $? -ne 0 ]; then
    return 1
  fi
  if [ ! -d ${name} ]; then
    rm -rf ${name} && git clone ${url}
    if [ $? -ne 0 ]; then
      cd "${cur_dir}"
      return 2
    fi
  fi
  if [ ! -z ${version} ]; then
    cd ${name} && git checkout ${version}
    if [ $? -ne 0 ]; then
      cd "${cur_dir}"
      return 3
    fi
  fi
  cd "${cur_dir}"
  return 0
}

git_download https://github.com/openssl/openssl openssl openssl-3.0.1
git_download https://github.com/Kitware/CMake CMake v3.22.3
git_download https://github.com/gflags/gflags gflags v2.2.2
git_download https://github.com/google/googletest googletest release-1.11.0
git_download https://github.com/madler/zlib zlib v1.2.11
git_download https://github.com/protocolbuffers/protobuf protobuf v3.14.0
git_download https://github.com/google/leveldb leveldb 1.23
git_download https://github.com/google/snappy snappy 1.1.9
git_download https://github.com/apache/incubator-brpc incubator-brpc 1.0.0
git_download https://github.com/swig/swig swig v4.0.2
git_download https://github.com/facebookresearch/faiss faiss v1.7.2

git_download https://github.com/spotify/annoy annoy v1.17.0
git_download https://github.com/nmslib/hnswlib hnswlib v0.6.2

git_download https://github.com/fmtlib/fmt fmt 8.1.1
git_download https://github.com/gabime/spdlog spdlog v1.9.2
git_download https://github.com/jupp0r/prometheus-cpp prometheus-cpp v1.0.0
git_download https://github.com/Tessil/robin-map robin-map v0.6.3
git_download https://github.com/yandaren/zk_cpp zk_cpp
git_download https://github.com/mavam/libbf libbf v1.0.0

# add_compile_options(-fPIC)

# openssl
if [ ! -d ${THIRD_LIB}/openssl ]; then
  cd ${THIRD_SRC}/openssl && make clean
  ./Configure --prefix=${THIRD_LIB}/openssl
  make -j8 && make install
fi
export PATH=${THIRD_LIB}/openssl/bin:${PATH}
export LD_LIBRARY_PATH=${THIRD_LIB}/openssl/lib64:${LD_LIBRARY_PATH}

# cmake
if [ ! -d ${THIRD_LIB}/cmake ]; then
  cd ${THIRD_SRC}/CMake && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/cmake \
        -DOPENSSL_ROOT_DIR=${THIRD_LIB}/openssl \
        -DOPENSSL_CRYPTO_LIBRARY=${THIRD_LIB}/openssl/lib64/libcrypto.so \
        -DOPENSSL_SSL_LIBRARY=${THIRD_LIB}/openssl/lib64/libssl.so ..
  make -j8 && make install
fi
export PATH=${THIRD_LIB}/cmake/bin:${PATH}

# gflags
if [ ! -d ${THIRD_LIB}/gflags ]; then
  cd ${THIRD_SRC}/gflags && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/gflags ..
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/gflags/lib:${LD_LIBRARY_PATH}

# gtest
if [ ! -d ${THIRD_LIB}/gtest ]; then
  cd ${THIRD_SRC}/googletest && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/gtest ..
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/gtest/lib:${LD_LIBRARY_PATH}

# zlib
if [ ! -d ${THIRD_LIB}/zlib ]; then
  cd ${THIRD_SRC}/zlib && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/zlib ..
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/zlib/lib:${LD_LIBRARY_PATH}

# protobuf
if [ ! -d ${THIRD_LIB}/protobuf ]; then
  cd ${THIRD_SRC}/protobuf && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_CXX_FLAGS="-fPIC" \
        -Dprotobuf_BUILD_TESTS=OFF \
        -DZLIB_INCLUDE_DIR=${THIRD_LIB}/zlib/include \
        -DZLIB_LIBRARY=${THIRD_LIB}/zlib/lib/libz.so \
        -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/protobuf ../cmake
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/protobuf/lib:${LD_LIBRARY_PATH}

# leveldb
if [ ! -d ${THIRD_LIB}/leveldb ]; then
  cd ${THIRD_SRC}/leveldb && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_CXX_FLAGS="-fPIC" \
        -DLEVELDB_BUILD_TESTS=0 \
        -DLEVELDB_BUILD_BENCHMARKS=0 \
        -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/leveldb \
        -DCMAKE_BUILD_TYPE=Release ..
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/leveldb/lib:${LD_LIBRARY_PATH}

# snappy
if [ ! -d ${THIRD_LIB}/snappy ]; then
  cd ${THIRD_SRC}/snappy && rm -rf build && mkdir build && cd build
  cmake -DCMAKE_CXX_FLAGS="-fPIC" \
        -DSNAPPY_BUILD_TESTS=0 \
        -DSNAPPY_BUILD_BENCHMARKS=0 \
        -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/snappy ..
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/snappy/lib:${LD_LIBRARY_PATH}

# brpc
if [ ! -d ${THIRD_LIB}/brpc ]; then
  cd ${THIRD_SRC}/incubator-brpc
  sh config_brpc.sh --headers=${THIRD_LIB}/*/include/ --libs=${THIRD_LIB}/*/*/
  make -j8 && make install
  mkdir ${THIRD_LIB}/brpc && cp -r output/* ${THIRD_LIB}/brpc
  cd example/echo_c++ && make
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/brpc/lib:${LD_LIBRARY_PATH}

# pcre
if [ ! -d ${THIRD_LIB}/pcre ]; then
  cd ${THIRD_SRC} && rm -rf pcre*
  wget --no-check-certificate https://onboardcloud.dl.sourceforge.net/project/pcre/pcre/8.45/pcre-8.45.tar.bz2
  tar xjvf pcre-8.45.tar.bz2
  cd pcre-8.45 && ./configure --prefix=${THIRD_LIB}/pcre
  make -j8 && make install
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/pcre/lib:${LD_LIBRARY_PATH}

# swig
# sudo apt install autoconf automake bison
if [ ! -d ${THIRD_LIB}/swig ]; then
  cd ${THIRD_SRC}/swig
  ./autogen.sh
  ./configure --prefix=${THIRD_LIB}/swig --with-pcre-prefix=${THIRD_LIB}/pcre
  make -j8 && make install
fi
export PATH=${THIRD_LIB}/swig/bin:${PATH}

# faiss
# sudo apt install intel-mkl
if [ ! -d ${THIRD_LIB}/faiss ]; then
cd ${THIRD_SRC}/faiss && rm -rf build
  cmake -DCMAKE_CXX_FLAGS="-fPIC" \
        -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/faiss \
        -DFAISS_ENABLE_GPU=OFF \
        -DBUILD_TESTING=OFF \
        -DBUILD_SHARED_LIBS=ON \
        -DFAISS_ENABLE_PYTHON=ON \
        -DCMAKE_BUILD_TYPE=Release \
        -DFAISS_OPT_LEVEL=avx2 \
        -DBLA_VENDOR=Intel10_64_dyn \
        -DMKL_LIBRARIES="/usr/lib/x86_64-linux-gnu/libmkl_rt.so;-lpthread;-lm;-ldl" \
        -DPython_EXECUTABLE="/home/john/anaconda3/envs/py3.7/bin/python" \
        -B build .
  make -C build -j8 faiss
  make -C build -j8 swigfaiss
  # cd build/faiss/python && python setup.py install
  make -C build install

  export LD_LIBRARY_PATH=${THIRD_LIB}/pcre/lib:${LD_LIBRARY_PATH}

  make -C build demo_ivfpq_indexing
  ./build/demos/demo_ivfpq_indexing
else
  export LD_LIBRARY_PATH=${THIRD_LIB}/pcre/lib:${LD_LIBRARY_PATH}
fi
export LD_LIBRARY_PATH=${THIRD_LIB}/faiss/lib:${LD_LIBRARY_PATH}


