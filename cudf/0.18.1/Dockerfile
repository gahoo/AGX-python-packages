FROM python:3.8-cuda10.2 as base

ENV ARROW_HOME=/usr/local/arrow/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/arrow/lib:/usr/lib/aarch64-linux-gnu/tegra/:/usr/local/dlpack/lib:/usr/local/rmm/lib

COPY --from=python:3.8-cuda10.2-arrow1.0.1 /usr/local/arrow /usr/local/arrow

COPY --from=rmm:0.18 /usr/local/dlpack /usr/local/dlpack
COPY --from=rmm:0.18 /usr/local/rmm /usr/local/rmm

FROM base as build
RUN apt update && \
    apt install -y unzip git libboost-filesystem-dev libboost-system-dev libprotobuf-dev thrift-compiler

RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

#RUN git clone http://172.17.0.1:3000/gahoo/cudf.git && \
#    cd cudf && \
#    git checkout v0.18.1 && \
#    cd cpp && \
RUN wget http://172.17.0.1:3000/gahoo/cudf/archive/v0.18.1.tar.gz && \
    tar -xf v0.18.1.tar.gz && \
    cd cudf/cpp && \
    find cmake thirdparty/ -name "*CMakeLists.txt*"|xargs sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' -i && \
    sed 's#gahoo#fork#g' cmake/Templates/Arrow.CMakeLists.txt.cmake -i && \
    mkdir build && cd build && \
    export ARROW_ROOT=/usr/local/arrow/ && \
    export CPLUS_INCLUDE_PATH=/usr/local/dlpack/include/:/usr/local/rmm/include/ && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/cudf/ -DCMAKE_CUDA_ARCHITECTURES=72 && \
    make -j 8 && \
    make install

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cudf/lib/
RUN wget http://172.17.0.1:9000/github.com/google/protobuf/releases/download/v3.12.1/protobuf-all-3.12.1.tar.gz && \
    tar -xf protobuf-all-3.12.1.tar.gz && \
    cd protobuf-3.12.1/ && \
    ./configure --prefix=/usr/local/ && \
    make -j 8 && \
    make install && \
    rm -r ../protobuf-all-3.12.1.tar.gz ../protobuf-3.12.1/

RUN cd /cudf/python/cudf && \
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ numpy Cython pyarrow==1.0.1dev rmm==0.18 && \
    export PARALLEL_LEVEL=8 && \
    #export CPLUS_INCLUDE_PATH=/usr/local/dlpack/include/:/usr/local/rmm/include/ && \
    ln -s /opt/venv/lib/python3.8/site-packages/pyarrow/libarrow_python.so.100 /opt/venv/lib/python3.8/site-packages/pyarrow/libarrow_python.so && \
    #sed '109 i \            os.path.join(CUDF_ROOT, "_deps/dlpack-src/include"),' setup.py -i && \
    #sed '109 i \            os.path.join(CUDF_ROOT, "_deps/spdlog-src/include"),' setup.py -i && \
    #sed '109 i \            os.path.join(CUDF_ROOT, "_deps/rmm-src/include"),' setup.py -i && \
    sed '109 i \            "/usr/local/dlpack/include/",' setup.py -i && \
    sed '109 i \            "/usr/local/rmm/include/",' setup.py -i && \
    sed '115 i \            + ["/usr/local/cuda/lib64/"]' setup.py -i && \
    sed '115 i \            + ["/usr/local/cudf/lib/"]' setup.py -i && \
    sed 's#libraries=.*#libraries=["cudf", "cudf_base", "cudf_ast", "cudf_comms", "cudf_hash", "cudf_interop", "cudf_io", "cudf_join", "cudf_merge", "cudf_partitioning", "cudf_reductions", "cudf_replace", "cudf_reshape", "cudf_rolling", "cudf_transpose", "cudart", "cuda"] + pa.get_libraries() + ["arrow_cuda"],#g' setup.py -i && \
    python setup.py build_ext && \
    python setup.py bdist_wheel && \
    pip install dist/cudf-*.whl

RUN pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ numpy Cython pyarrow==1.0.1dev rmm==0.18 cupy nvtx && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ pandas==1.2.3 && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ packaging fsspec cachetools typing_extensions protobuf

RUN cd /cudf/python/dask_cudf && \
    sed 's#git_refnames = .*#git_refnames = " (tag: v0.18.1, main)"#g' dask_cudf/_version.py -i && \
    sed 's#git_full = .*#git_full = "999be56c805bcdca93ce818c1646468aed82d2c4"#g' dask_cudf/_version.py -i && \
    sed 's#git_date = .*#git_date = "2021-03-15 17:17:51 -0400"#g' dask_cudf/_version.py -i && \
    python setup.py build_ext && \
    python setup.py bdist_wheel && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ dist/dask_cudf-*.whl

RUN git clone http://172.17.0.1:3000/gahoo/librdkafka.git && \
    cd librdkafka/ && \
    git checkout v1.6.1 && \
    apt install -y libzstd-dev liblz4-dev rapidjson-dev && \
    ./configure --prefix=/usr/local/librdkafka/ && \
    make -j 8 && \
    make install

#libcudf_kafka
RUN cd /cudf/cpp/libcudf_kafka && \
    sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' cmake/Templates/GoogleTest.CMakeLists.txt.cmake -i && \
    mkdir build && cd build && \
    export CPLUS_INCLUDE_PATH=/usr/local/dlpack/include/:/usr/local/rmm/include/:/usr/local/cudf/include/:/usr/local/arrow/include/:/usr/local/librdkafka/include/ && \
    export RDKAFKA_ROOT=/usr/local/librdkafka && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/venv/lib/ && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/cudf/ -DCMAKE_CUDA_ARCHITECTURES=72 && \
    sed 's#$#-L/usr/local/cudf/lib/ #g' CMakeFiles/cudf_kafka.dir/link.txt tests/CMakeFiles/CUDF_KAFKA_HOST_READ.dir/link.txt -i && \
    make -j 8 && \
    make install

RUN cd /cudf/python/cudf_kafka && \
    sed '59 i \            "/usr/local/arrow/include/",' setup.py -i && \
    sed '59 i \            "/usr/local/rmm/include/",' setup.py -i && \
    sed '59 i \            "/usr/local/librdkafka/include/",' setup.py -i && \
    sed 's#library_dirs=.*#library_dirs=([get_python_lib(), os.path.join(os.sys.prefix, "lib"), "/usr/local/librdkafka/lib/", "/usr/local/cudf/lib/"]),#g' setup.py -i && \
    sed 's#git_refnames = .*#git_refnames = " (tag: v0.18.1, main)"#g' cudf_kafka/_version.py -i && \
    sed 's#git_full = .*#git_full = "999be56c805bcdca93ce818c1646468aed82d2c4"#g' cudf_kafka/_version.py -i && \
    sed 's#git_date = .*#git_date = "2021-03-15 17:17:51 -0400"#g' cudf_kafka/_version.py -i && \
    python setup.py build_ext && \
    python setup.py bdist_wheel && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ dist/cudf_kafka-*.whl

RUN cd /cudf/python/custreamz && \
    sed 's#git_refnames = .*#git_refnames = " (tag: v0.18.1, main)"#g' custreamz/_version.py -i && \
    sed 's#git_full = .*#git_full = "999be56c805bcdca93ce818c1646468aed82d2c4"#g' custreamz/_version.py -i && \
    sed 's#git_date = .*#git_date = "2021-03-15 17:17:51 -0400"#g' custreamz/_version.py -i && \
    python setup.py build_ext && \
    python setup.py bdist_wheel && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ dist/custreamz-*.whl

RUN git clone http://172.17.0.1:3000/gahoo/confluent-kafka-python.git && \
    cd confluent-kafka-python && \
    git checkout v1.6.0 && \
    sed '49 i \                   include_dirs=["/usr/local/librdkafka/include/"],' setup.py -i && \
    sed '49 i \                   library_dirs=["/usr/local/librdkafka/lib/"],' setup.py -i && \
    python setup.py bdist_wheel && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ dist/confluent_kafka-*.whl

FROM python:3.8-cuda10.2

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/arrow/lib:/usr/lib/aarch64-linux-gnu/tegra/:/usr/local/dlpack/lib:/usr/local/rmm/lib:/usr/local/cudf/lib/:/usr/local/librdkafka/lib/

RUN apt install -y libboost-filesystem-dev libboost-system-dev
COPY --from=python:3.8-cuda10.2-arrow1.0.1 /usr/local/arrow /usr/local/arrow
COPY --from=rmm:0.18 /usr/local/dlpack /usr/local/dlpack
COPY --from=rmm:0.18 /usr/local/rmm /usr/local/rmm
COPY --from=build /usr/local/cudf /usr/local/cudf
COPY --from=build /usr/local/librdkafka /usr/local/librdkafka
COPY --from=build /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages
#COPY requirements.txt /tmp/requirements.txt
#RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ -r /tmp/requirements.txt
