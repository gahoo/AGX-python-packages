FROM python:3.8-cuda10.2

RUN sed 's#ports.ubuntu.com#mirrors.aliyun.com#g' /etc/apt/sources.list -i && \
    echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy && \
    echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

RUN apt update && \
    apt install -y cmake build-essential wget && \
    wget http://172.17.0.1:9000/github.com/llvm/llvm-project/archive/llvmorg-11.1.0.tar.gz && \
    tar -xf llvmorg-11.1.0.tar.gz && \
    cd llvm-project-llvmorg-11.1.0 && \
    cmake -S llvm -G 'Unix Makefiles' -DLLVM_ENABLE_PROJECTS="clang" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-11.1 && \
    make -j 8 && \
    make install && \
    rm -r /tmp/* /llvmorg-11.1.0.tar.gz /llvm-project-llvmorg-11.1.0 /var/lib/apt/lists/* && \
    apt clean
