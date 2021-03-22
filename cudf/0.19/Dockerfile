FROM python:3.8-cuda10.2 as build

ENV ARROW_HOME=/usr/local/arrow/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$ARROW_HOME/lib:/usr/lib/aarch64-linux-gnu/tegra/

COPY --from=python:3.8-cuda10.2-arrow1.0.1 /usr/local/arrow /usr/local/arrow

RUN apt update && \
    apt install -y unzip git libboost-filesystem-dev libboost-system-dev libprotobuf-dev libprotoc-dev thrift-compiler

RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

RUN git clone http://172.17.0.1:3000/gahoo/cudf.git && \
    cd cudf && \
    git checkout branch-0.19 && \
    cd cpp && \
    sed 's#https://#http://172.17.0.1:9000/#g' cmake/thirdparty/CUDF_GetCPM.cmake -i && \
    find cmake/thirdparty/ -name "*.cmake"|xargs sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' -i && \
    sed 's#gahoo#fork#g' cmake/thirdparty/CUDF_GetArrow.cmake cmake/thirdparty/CUDF_GetRMM.cmake -i && \
    mkdir build && cd build && \
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/tegra/ && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/cudf/ -DCMAKE_CUDA_ARCHITECTURES=72-real && \
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
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ numpy Cython pyarrow==1.0.1dev rmm && \
    export PARALLEL_LEVEL=8 && \
    ln -s /opt/venv/lib/python3.8/site-packages/pyarrow/libarrow_python.so.100 /opt/venv/lib/python3.8/site-packages/pyarrow/libarrow_python.so && \
    sed '109 i \            os.path.join(CUDF_ROOT, "_deps/dlpack-src/include"),' setup.py -i && \
    sed '109 i \            os.path.join(CUDF_ROOT, "_deps/spdlog-src/include"),' setup.py -i && \
    sed '109 i \            os.path.join(CUDF_ROOT, "_deps/rmm-src/include"),' setup.py -i && \
    sed '124 i \            + ["/usr/local/cuda/lib64/"]' setup.py -i && \
    sed '124 i \            + ["/usr/local/cudf/lib/"]' setup.py -i && \
    sed 's#libraries=.*#libraries=["cudf","cudart","cuda"] + pa.get_libraries() + ["arrow_cuda"],#g' setup.py -i && \
    python setup.py bdist_wheel && \
    pip install dist/cudf-*.whl
RUN pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ numpy Cython pyarrow==1.0.1dev rmm cupy nvtx && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ pandas==1.2.3 && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ packaging fsspec cachetools typing_extensions protobuf

FROM python:3.8-cuda10.2

ENV ARROW_HOME=/usr/local/arrow/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/tegra/:/usr/local/arrow/lib/:/usr/local/cudf/lib/

COPY requirements.txt /tmp/requirements.txt

COPY --from=python:3.8-cuda10.2-arrow1.0.1 /usr/local/arrow /usr/local/arrow
COPY --from=build /usr/local/arrow /usr/local/arrow
RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ -r /tmp/requirements.txt
