FROM python:3.8-cuda10.2 as builder

# dependencies
RUN export MAKEFLAGS="-j"`nproc` && \
    apt update && apt upgrade -y && \
    apt install -y git \
        wget \
        libssl-dev \
        autoconf \
        flex \
        bison \
        llvm-7 \
        clang \
        cmake \
        python3-pip \
        libcurl4-openssl-dev \
        libjemalloc-dev \
        libboost-dev \
        libboost-filesystem-dev \
        libboost-system-dev \
        libboost-regex-dev \
        unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#RUN wget http://172.17.0.1:9000/github.com/llvm/llvm-project/releases/download/llvmorg-11.1.0/clang+llvm-11.1.0-aarch64-linux-gnu.tar.gz && \
#    mkdir -p /usr/local/llvm-11.1/ && \
#    tar -xf clang+llvm-11.1.0-aarch64-linux-gnu.tar.gz -C /usr/local/llvm-11.1/ && \
#    rm clang+llvm-11.1.0-aarch64-linux-gnu.tar.gz && \
#    export PATH=$PATH:/usr/local/llvm-11.1/bin/

# newer version required
#    libgrpc-dev \
#    libgrpc++-dev \

# python dependencies
RUN pip install cython wheel setuptools_scm && \
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ pandas==1.2.3 && \
    pip install pytest hypothesis

# Step 3: Cloning Apache Arrow From GitHub
RUN wget http://172.17.0.1:9000/github.com/apache/arrow/archive/apache-arrow-0.16.0.tar.gz && \
    tar -xf apache-arrow-0.16.0.tar.gz && \
    cd arrow-apache-arrow-0.16.0/ && \
# parquet testing
#    wget http://172.17.0.1:9000/github.com/apache/parquet-testing/archive/master.zip && \
#    unzip master.zip && \
#    mv parquet-testing-master cpp/submodules/parquet-testing && \
#    rm master.zip && \
#    export PARQUET_TEST_DATA="${PWD}/cpp/submodules/parquet-testing/data" && \
#    export ARROW_TEST_DATA="${PWD}/testing/data" && \
# sed versions.txt
    cd cpp && \
    sed 's#https://#http://172.17.0.1:9000/#g' ./thirdparty/versions.txt ./cmake_modules/ThirdpartyToolchain.cmake -i

# Step 5: Building Apache Arrow C++ Library
ENV ARROW_HOME=/usr/local/arrow
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARROW_HOME/lib:/usr/lib/aarch64-linux-gnu/tegra/

RUN cd /arrow-apache-arrow-0.16.0/cpp && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=$ARROW_HOME \
    -DARROW_DEPENDENCY_SOURCE=BUNDLED \
    -DARROW_CSV=ON \
    -DARROW_JSON=ON \
    -DCMAKE_INSTALL_LIBDIR=lib \
    -DARROW_FILESYSTEM=ON \
    -DARROW_S3=OFF \
    -DARROW_FLIGHT=ON \
    -DARROW_GANDIVA=ON \
    -DARROW_ORC=ON \
    -DARROW_WITH_BZ2=ON \
    -DARROW_WITH_ZLIB=ON \
    -DARROW_WITH_ZSTD=ON \
    -DARROW_WITH_LZ4=ON \
    -DARROW_WITH_SNAPPY=ON \
    -DARROW_WITH_BROTLI=ON \
    -DARROW_PARQUET=ON \
    -DARROW_PYTHON=ON \
    -DARROW_PLASMA=ON \
    -DARROW_BUILD_TESTS=ON \
    -DARROW_CUDA=ON  && \
# Fix broken linking to zlib
    sed '129 i release/flight-test-server: zlib_ep/src/zlib_ep-install/lib/libz.so' src/arrow/flight/CMakeFiles/flight-test-server.dir/build.make -i && \
    sed '137 i release/arrow-flight-test: zlib_ep/src/zlib_ep-install/lib/libz.so' src/arrow/flight/CMakeFiles/arrow-flight-test.dir/build.make -i && \
    sed 's# -pthread# ../../../zlib_ep/src/zlib_ep-install/lib/libz.so -pthread#g' src/arrow/flight/CMakeFiles/flight-test-server.dir/link.txt -i && \
    sed 's#$# ../../../zlib_ep/src/zlib_ep-install/lib/libz.so#g' src/arrow/flight/CMakeFiles/arrow-flight-test.dir/link.txt -i && \
    make -j $(nproc) && \
    make install
    
# Step 6: Building Pyarrow Wheel
RUN cd /arrow-apache-arrow-0.16.0/python && \
    export PYARROW_WITH_PARQUET=ON && \
    export PYARROW_WITH_CUDA=ON && \
    python setup.py build_ext --build-type=release --bundle-arrow-cpp bdist_wheel && \
    #cmake --build . --config release --
    pip install dist/pyarrow-0.16.0-cp38-cp38-linux_aarch64.whl


FROM python:3.8-cuda10.2

ENV ARROW_HOME=/usr/local/arrow/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARROW_HOME/lib:/usr/lib/aarch64-linux-gnu/tegra/

COPY --from=builder /usr/local/arrow /usr/local/arrow
COPY --from=builder /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages
