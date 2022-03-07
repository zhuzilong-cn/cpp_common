#!/bin/bash

WORK_DIR=/home/john/work/cpp
THIRD_LIB=${WORK_DIR}/third-lib
THIRD_SRC=${WORK_DIR}/third-src

mkdir -p ${THIRD_LIB}
mkdir -p ${THIRD_SRC}

function git_download()
{
	local url=${1}
	local name=${2}
	local version=${3}

	mkdir -p ${THIRD_SRC} && cd ${THIRD_SRC}
	if [ $? -ne 0 ]; then
		return 1
	fi
	if [ ! -d ${name} ]; then
		rm -rf ${name} && git clone ${url}
		if [ $? -ne 0 ]; then
			return 2
		fi
	fi
	cd ${name} && git checkout ${version}
	if [ $? -ne 0 ]; then
		return 3
	fi
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

# add_compile_options(-fPIC)

# openssl
cd ${THIRD_SRC}/openssl && make clean
./Configure --prefix=${THIRD_LIB}/openssl
make -j8 && make install

export PATH=${THIRD_LIB}/openssl/bin:${PATH}
export LD_LIBRARY_PATH=${THIRD_LIB}/openssl/lib64:${LD_LIBRARY_PATH}

# cmake
cd ${THIRD_SRC}/CMake && rm -rf build && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/cmake -DOPENSSL_ROOT_DIR=${THIRD_LIB}/openssl -DOPENSSL_CRYPTO_LIBRARY=${THIRD_LIB}/openssl/lib64/libcrypto.so -DOPENSSL_SSL_LIBRARY=${THIRD_LIB}/openssl/lib64/libssl.so ..
make -j8 && make install

export PATH=${THIRD_LIB}/cmake/bin:${PATH}

# gflags
cd ${THIRD_SRC}/gflags && rm -rf build && mkdir build && cd build
cmake -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/gflags ..
make -j8 && make install

export LD_LIBRARY_PATH=${THIRD_LIB}/gflags/lib:${LD_LIBRARY_PATH}

# gtest
cd ${THIRD_SRC}/googletest && rm -rf build && mkdir build && cd build
cmake -DCMAKE_CXX_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/gtest ..
make -j8 && make install

export LD_LIBRARY_PATH=${THIRD_LIB}/gtest/lib:${LD_LIBRARY_PATH}

# zlib
cd ${THIRD_SRC}/zlib && rm -rf build && mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/zlib ..
make -j8 && make install

export LD_LIBRARY_PATH=${THIRD_LIB}/zlib/lib:${LD_LIBRARY_PATH}

# protobuf
cd ${THIRD_SRC}/protobuf && rm -rf build && mkdir build && cd build
cmake -DCMAKE_CXX_FLAGS="-fPIC" -Dprotobuf_BUILD_TESTS=OFF -DZLIB_INCLUDE_DIR=${THIRD_LIB}/zlib/include -DZLIB_LIBRARY=${THIRD_LIB}/zlib/lib/libz.so -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/protobuf ../cmake
make -j8 && make install

export LD_LIBRARY_PATH=${THIRD_LIB}/protobuf/lib:${LD_LIBRARY_PATH}

# leveldb
cd ${THIRD_SRC}/leveldb && rm -rf build && mkdir build && cd build
cmake -DCMAKE_CXX_FLAGS="-fPIC" -DLEVELDB_BUILD_TESTS=0 -DLEVELDB_BUILD_BENCHMARKS=0 -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/leveldb -DCMAKE_BUILD_TYPE=Release ..
make -j8 && make install

export LD_LIBRARY_PATH=${THIRD_LIB}/leveldb/lib:${LD_LIBRARY_PATH}

# snappy
cd ${THIRD_SRC}/snappy && rm -rf build && mkdir build && cd build
cmake -DCMAKE_CXX_FLAGS="-fPIC" -DSNAPPY_BUILD_TESTS=0 -DSNAPPY_BUILD_BENCHMARKS=0 -DCMAKE_INSTALL_PREFIX=${THIRD_LIB}/snappy ..
make -j8 && make install

export LD_LIBRARY_PATH=${THIRD_LIB}/snappy/lib:${LD_LIBRARY_PATH}

# brpc
cd ${THIRD_SRC}/incubator-brpc
sh config_brpc.sh --headers=${THIRD_LIB}/*/include/ --libs=${THIRD_LIB}/*/*/
make -j8 && make install
mkdir ${THIRD_LIB}/brpc && cp -r output/* ${THIRD_LIB}/brpc
cd example/echo_c++ && make

export LD_LIBRARY_PATH=${THIRD_LIB}/brpc/lib:${LD_LIBRARY_PATH}

