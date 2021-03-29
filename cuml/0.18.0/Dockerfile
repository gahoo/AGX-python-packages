FROM cudf:0.18.1 as build

RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

COPY --from=nccl:2.8.3 /nccl/build/pkg/deb /tmp
#COPY --from=faiss:1.7.0 /usr/local/faiss/ /usr/local/faiss/
COPY --from=googletest:1.10.0 /usr/local/googletest /usr/local
COPY --from=treelite:1.0.0 /usr/local/treelite/ /usr/local/treelite/
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/treelite/lib/

RUN apt install -y git zlib1g-dev libopenblas-dev libopenmpi-dev libomp-dev doxygen googletest && \
    dpkg -i /tmp/libnccl2_2.8.3-1+cuda10.2_arm64.deb && \
    dpkg -i /tmp/libnccl-dev_2.8.3-1+cuda10.2_arm64.deb
#RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ faiss treelite==1.0.0

RUN wget http://172.17.0.1:3000/gahoo/cuml/archive/v0.18.0.tar.gz && \
    tar -xf v0.18.0.tar.gz && \
    cd cuml/cpp && \
    sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' cmake/Dependencies.cmake -i

# x64 from nvidia conda package which might fail on arm64
# https://anaconda.org/nvidia/libcumlprims/files
#RUN wget https://anaconda.org/nvidia/libcumlprims/0.18.0/download/linux-64/libcumlprims-0.18.0-cuda10.2_g5939d3e_0.tar.bz2 && \
#    tar -xf libcumlprims-0.18.0-cuda10.2_g5939d3e_0.tar.bz2 -C /usr/local/ && \
#    ln -s /usr/local/include/cumlprims/opg/ /usr/local/include/

RUN cd cuml/cpp && \
    mkdir build && cd build && \
    #export FAISS_ROOT=/usr/local/faiss/ && \
    export RMM_ROOT=/usr/local/rmm/ && \
    export TREELITE_ROOT=/usr/local/treelite/ && \
    export CPLUS_INCLUDE_PATH=/usr/local/treelite/include/ && \
    #export BLAS_LIBRARIES=/usr/lib/aarch64-linux-gnu/openblas/ && \
    cmake .. \
      -DCMAKE_INSTALL_PREFIX=/usr/local/cuml \
      -DCMAKE_VERBOSE_MAKEFILE=TRUE \
      -DCMAKE_BUILD_TYPE=Release \
      -DPARALLEL_LEVEL=8 \
      -DCMAKE_CUDA_ARCHITECTURES=72 \
      -DGPU_ARCHS="72" \
      -DBUILD_STATIC_FAISS=ON \
      -DSINGLEGPU=ON \
      -DNVTX=ON && \
#      -DWITH_UCX=ON \
#      -DBUILD_CUML_MPI_COMMS=ON \
#      -DKERNEL_INFO=ON \
#      -DLINE_INFO=ON \
#      -DENABLE_CUMLPRIMS_MG=OFF \
#      -DBUILD_CUML_PRIMS_BENCH=OFF \
#      -DBUILD_GTEST=ON \
    sed 's#$# -lblas#g' CMakeFiles/cuml++.dir/link.txt -i && \
    make -j 8 && \
    make install

RUN cd cuml/python && \
    export CUML_BUILD_PATH=/cuml/cpp/build/ && \
    python setup.py build_ext -l cudart -l cuda --include-dirs="/usr/local/rmm/include/:/usr/local/treelite/include/:../cpp/build/faiss/include/" -j 8 --inplace --singlegpu && \
    python setup.py bdist_wheel --skip-build && \
    pip install dist/cuml-*.whl


FROM cudf:0.18.1

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuml/lib/
COPY --from=build /usr/local/cuml /usr/local/cuml
COPY --from=build /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages
