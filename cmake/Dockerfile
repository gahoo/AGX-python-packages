FROM python:3.8-cuda10.2

RUN wget http://172.17.0.1:9000/github.com/Kitware/CMake/releases/download/v3.19.6/cmake-3.19.6-Linux-aarch64.tar.gz && \
    tar -xf cmake-3.19.6-Linux-aarch64.tar.gz -C /usr/local/ && \
    mv /usr/local/cmake-3.19.6-Linux-aarch64 /usr/local/cmake && \
    rm cmake-3.19.6-Linux-aarch64.tar.gz

ENV PATH=$PATH:/usr/local/cmake/bin:/usr/local/cuda-10.2/bin

RUN apt install -y unzip git
