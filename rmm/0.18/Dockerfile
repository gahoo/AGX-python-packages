FROM python:3.8-cuda10.2 AS compile-image

RUN apt install -y unzip git libboost-filesystem-dev libboost-system-dev
RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

RUN git clone http://172.17.0.1:3000/gahoo/dlpack.git && \
    cd dlpack && \
    git checkout v0.3 && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/dlpack && \
    make -j 8 && \
    make install && \
    cd ../../ && rm -r dlpack

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/dlpack/lib
RUN git clone --recurse-submodules http://172.17.0.1:3000/gahoo/rmm.git && \
    cd rmm && \
    git checkout v0.18.0 && \
    git submodule update --init --recursive && \
    wget -O cmake/Modules/CPM.cmake http://172.17.0.1:9000/github.com/cpm-cmake/CPM.cmake/releases/download/v0.31.1/CPM.cmake && \
    sed 's#https://github.com/#http://172.17.0.1:3000/#g' cmake/Modules/CPM.cmake -i && \
    sed -E 's#(NVIDIA|gabime)#gahoo#g' cmake/Modules/RMM_thirdparty.cmake -i && \
    sed 's#google/googletest#gahoo/googletest#g' tests/CMakeLists.txt -i && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/rmm && \
    make -j 8 && \
    make install

RUN cd /rmm/python && \
    sed 's#^library_dirs.*$#library_dirs = [get_python_lib(), os.path.join(os.sys.prefix, "lib"), cuda_lib_dir]#g' setup.py -i && \
    export INSTALL_PREFIX=/usr/local/rmm/ && \
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ Cython && \
    python setup.py build_ext --inplace && \
    python setup.py bdist_wheel && \
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ numba==0.52.0 && \
    pip install dist/rmm-0.18.0-cp38-cp38-linux_aarch64.whl

FROM python:3.8-cuda10.2

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/aarch64-linux-gnu/tegra/:/usr/local/dlpack/lib:/usr/local/rmm/lib

COPY --from=compile-image /usr/local/dlpack /usr/local/dlpack
COPY --from=compile-image /usr/local/rmm /usr/local/rmm
COPY --from=compile-image /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages
