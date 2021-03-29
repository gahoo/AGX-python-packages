FROM python:3.8-cuda10.2
ARG VERSION=v2.8.3-1

RUN apt install -y build-essential devscripts debhelper fakeroot

RUN wget http://172.17.0.1:3000/gahoo/nccl/archive/$VERSION.tar.gz && \
    tar -xf $VERSION.tar.gz && \
    cd nccl/ && \
    make -j8 src.build NVCC_GENCODE="-gencode=arch=compute_72,code=sm_72" && \
    make pkg.debian.build

RUN dpkg -i /nccl/build/pkg/deb/libnccl2_*_arm64.deb && \
    dpkg -i /nccl/build/pkg/deb/libnccl-dev_*_arm64.deb
