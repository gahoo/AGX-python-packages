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
        llvm-10 \
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

# newer version required
#    libgrpc-dev \
#    libgrpc++-dev \

# python dependencies
RUN pip install cython wheel setuptools_scm && \
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ pandas==1.2.3 && \
    pip install pytest hypothesis

# Step 3: Cloning Apache Arrow From GitHub
RUN git clone http://172.17.0.1:3000/fork/arrow.git && \
    cd arrow/ && \
    git checkout apache-arrow-1.0.1 && \
    git submodule update --init --recursive && \
    cd cpp && \
    sed 's#https://#http://172.17.0.1:9000/#g' ./thirdparty/versions.txt ./cmake_modules/ThirdpartyToolchain.cmake -i

# Step 5: Building Apache Arrow C++ Library
ENV ARROW_HOME=/usr/local/arrow
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARROW_HOME/lib:/usr/lib/aarch64-linux-gnu/tegra/

RUN cd /arrow/cpp && \
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
    -DARROW_GANDIVA_STATIC_LIBSTDCPP=ON \
    -DARROW_CUDA=ON  && \
    make -j $(nproc) && \
    make install
    
# Step 6: Building Pyarrow Wheel
RUN cd /arrow/python && \
    sed 's#${ARROW_ARMV8_ARCH}#armv8-a#g' cmake_modules/SetupCxxFlags.cmake -i && \
    python setup.py build_ext \
        --build-type=release \
        --bundle-arrow-cpp \
        --with-cuda \
        --with-flight \
        --with-parquet \
        --with-static-parquet \
        --with-plasma \
        #--with-tensorflow \
        --with-orc \
        --with-dataset \
        --with-gandiva \
        --extra-cmake-args "-DThrift_ROOT=/arrow/cpp/build/thrift_ep-install/" \
        bdist_wheel && \
    pip install dist/pyarrow-1.0.1.dev*-cp38-cp38-linux_aarch64.whl


FROM python:3.8-cuda10.2

ENV ARROW_HOME=/usr/local/arrow/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARROW_HOME/lib:/usr/lib/aarch64-linux-gnu/tegra/

COPY --from=builder /usr/local/arrow /usr/local/arrow
COPY --from=builder /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages
