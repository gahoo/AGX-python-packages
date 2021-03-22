FROM python:3.8-cuda10.2-arrow0.16 AS compile-image

ENV DEBIAN_FRONTEND=noninteractive
RUN BUILDPKGS="build-essential git \
        libhdf5-dev libfreetype6-dev libtool \
        m4 autoconf automake patch bison flex libpng-dev libopenblas-dev \
        tcl-dev tk-dev libxml2-dev zlib1g-dev libffi-dev libtinfo-dev cmake" && \
    apt-get update && \
    apt-get install -y --no-install-recommends apt-utils debconf locales && dpkg-reconfigure locales && \
    apt-get install -y --no-install-recommends $BUILDPKGS

#RUN python -m venv /opt/venv
# Make sure we use the virtualenv:
#ENV PATH="/opt/venv/bin:$PATH"

# install dependencies:
COPY requirements_docker.txt /tmp/
RUN pip install --no-cache-dir --upgrade pip wheel && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ scipy==1.6.0 Cython==0.29.21 Pillow==8.1.0 pandas==1.2.2 && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ -r /tmp/requirements_docker.txt

# use version from argument (--build-arg version=0.11.0), or a default:
ARG version="0.11.0"
RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ pyscenic==$version && \
    pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ scanpy==1.7.0


FROM python:3.8-cuda10.2-arrow0.16

COPY --from=compile-image /opt/venv /opt/venv

RUN apt-get -y update && \
    apt-get -y --no-install-recommends install \
        # Need to run ps
        procps \
        libxml2 \
        less \
        git \
        libhdf5-dev \
        # Need to run MulticoreTSNE
        libgomp1 && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/*

