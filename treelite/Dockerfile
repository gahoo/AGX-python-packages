FROM python:3.8-cuda10.2 

RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

ARG VERSION=0.93
RUN apt install -y git
RUN wget http://172.17.0.1:3000/gahoo/treelite/archive/$VERSION.tar.gz && \
    tar -xf $VERSION.tar.gz && \
    cd treelite && \
    sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' cmake/ExternalLibs.cmake -i && \
    mkdir build && cd build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/treelite -DCMAKE_INSTALL_LIBDIR="lib" -DCMAKE_BUILD_TYPE=Release -DENABLE_PROTOBUF=ON && \
    make -j 8 && \
    make install

RUN cd /treelite/python/ && \
    pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ numpy scipy && \
    python setup.py bdist_wheel && \
    pip install dist/treelite-$VERSION-cp38-cp38-linux_aarch64.whl
