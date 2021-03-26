FROM python:3.8-cuda10.2 as build

RUN apt-get install -y swig git libopenblas-dev libomp-dev
RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ numpy
RUN git clone http://172.17.0.1:3000/gahoo/faiss.git && \
    cd faiss && \
    # fixed v1.7.0 fvec_inner_products_ny issue
    git checkout 27077c46274f87a50a0a28fb90433d6cfc029741 && \ 
    # used by cuml 0.18
    #git checkout a5b850dec6f1cd6c88ab467bfd5e87b0cac2e41d && \ 
    sed 's#https://github.com/google/#http://172.17.0.1:3000/gahoo/#g' ./tests/CMakeLists.txt -i && \
    cmake -B build . \
      -DCMAKE_INSTALL_PREFIX=/usr/local/faiss/ \
      -DCMAKE_VERBOSE_MAKEFILE=TRUE \
      -DFAISS_ENABLE_GPU=ON \
      -DFAISS_ENABLE_PYTHON=ON \
      -DBUILD_TESTING=ON \
      -DBUILD_SHARED_LIBS=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_CUDA_ARCHITECTURES="72"
      #-DFAISS_OPT_LEVEL=sse4 \
WORKDIR /faiss/build
RUN make -j8 faiss
RUN make -j8 swigfaiss
RUN make install
#RUN make test
RUN cd faiss/python && \
    sed '23 i \    shutil.copyfile("libfaiss_python_callbacks.so", "faiss/libfaiss_python_callbacks.so")' setup.py -i && \
    python setup.py bdist_wheel && \
    pip install dist/faiss-*.whl

FROM nvcr.io/nvidia/l4t-base:r32.4.4

RUN apt update && apt-get install -y libopenblas-dev libomp-dev
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/faiss/lib/
COPY --from=build /usr/local/faiss/ /usr/local/faiss/
COPY --from=build /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages
RUN ln -s /opt/venv/lib/python3.8/site-packages/faiss/libfaiss_python_callbacks.so /usr/local/faiss/lib/
