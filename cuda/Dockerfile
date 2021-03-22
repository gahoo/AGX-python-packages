FROM ubuntu:18.04

RUN sed 's#ports.ubuntu.com#mirrors.aliyun.com#g' /etc/apt/sources.list -i && \
    echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy && \
    echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

ENV CUDA_VERSION=10.2
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA=cuda>=10.2 brand=tesla,driver>=384,driver<385 brand=tesla,driver>=396,driver<397 brand=tesla,driver>=410,driver<411
ENV CUDA_HOME=/usr/local/cuda-${CUDA_VERSION}
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$CUDA_HOME/lib64:$CUDA_HOME/extras/CUPTI/lib64
ENV LD_PRELOAD_BLAS=/usr/lib/aarch64-linux-gnu/libnvblas.so
ENV NVBLAS_CONFIG_FILE=/etc/nvblas.conf
ARG SOC
ENV SOC=t194

# configure CUDA repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    gnupg2 wget curl ca-certificates && \
    wget http://172.17.0.1:9000/repo.download.nvidia.com/jetson/jetson-ota-public.asc -O /etc/apt/trusted.gpg.d/jetson-ota-public.asc && \
    chmod 644 /etc/apt/trusted.gpg.d/jetson-ota-public.asc && \
    echo "deb http://172.17.0.1:9000/cn-repo.download.nvidia.com/jetson/common r32.4 main" > /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    echo "deb http://172.17.0.1:9000/cn-repo.download.nvidia.com/jetson/${SOC} r32.4 main" >> /etc/apt/sources.list.d/nvidia-l4t-apt-source.list && \
    mkdir -p /opt/nvidia/l4t-packages/ && \
    touch /opt/nvidia/l4t-packages/.nv-l4t-disable-boot-fw-update-in-preinstall && \
    apt update

# install deb
RUN apt-get install -y libcublas10 cuda-cusparse-10-2
RUN apt-get install -y cuda-cufft-10-2 cuda-cudart-10-2
RUN apt-get install -y cuda-cusolver-10-2
RUN apt-get install -y cuda-command-line-tools-10-2 cuda-nvrtc-10-2 cuda-curand-10-2
RUN apt-get install -y nvidia-cuda

# post configure
RUN touch /var/log/nvblas.log && \
    chown :staff /var/log/nvblas.log && \
    chmod a+rw /var/log/nvblas.log && \
    echo -e 'NVBLAS_LOGFILE /var/log/nvblas.log\nNVBLAS_CPU_BLAS_LIB /usr/lib/aarch64-linux-gnu/openblas/libblas.so.3\nNVBLAS_GPU_LIST ALL' > /etc/nvblas.conf

