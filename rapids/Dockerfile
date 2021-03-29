from nvcr.io/nvidia/l4t-base:r32.4.4

RUN sed 's#ports.ubuntu.com#mirrors.aliyun.com#g' /etc/apt/sources.list -i && \
    echo 'Acquire::HTTP::Proxy "http://172.17.0.1:3142";' >> /etc/apt/apt.conf.d/01proxy && \
    echo 'Acquire::HTTPS::Proxy "false";' >> /etc/apt/apt.conf.d/01proxy

RUN apt update && \
    apt install --no-install-recommends -y python3.8 python3-pip python3.8-dev python3.8-venv && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2 && \
    apt clean

RUN apt install -y libboost-filesystem-dev libboost-system-dev

RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple -U pip && \
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    #pip3 config set global.trusted-host 172.17.0.1 && \
    #pip3 config set global.index-url http://172.17.0.1:9000/pypi/ && \
    #pip3 config set global.extra-index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip3 install wheel setuptools_scm

COPY --from=cudf:0.18.1 /usr/local/cudf /usr/local
COPY --from=python:3.8-cuda10.2-arrow1.0.1 /usr/local/arrow /usr/local

RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ rmm==0.18.0 cupy cudf==0.18.1 cuml==0.18.0 pyarrow==1.0.1dev
RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index https://mirrors.aliyun.com/pypi/simple pandas fsspec typing_extensions nvtx protobuf
RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index https://mirrors.aliyun.com/pypi/simple dask_cudf==0.18.1
RUN python3 -c 'import rmm, cudf, dask_cudf, cuml, pyarrow, cupy'
