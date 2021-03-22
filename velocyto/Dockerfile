FROM python:3.8-cuda10.2-arrow as base

RUN apt install -y libbz2-dev liblzma-dev libhdf5-dev pkg-config libtinfo-dev

FROM base as builder
RUN wget http://172.17.0.1:9000/github.com/llvm/llvm-project/releases/download/llvmorg-10.0.1/clang+llvm-10.0.1-aarch64-linux-gnu.tar.xz && \
    tar -xf clang+llvm-10.0.1-aarch64-linux-gnu.tar.xz && \
    mv clang+llvm-10.0.1-aarch64-linux-gnu /usr/local/llvm-10.0 && \
    rm clang+llvm-10.0.1-aarch64-linux-gnu.tar.xz

ENV PATH=$PATH:/usr/local/llvm-10.0/bin/

RUN pip3 install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ velocyto


FROM base

COPY --from=builder /opt/venv/lib/python3.8/site-packages /opt/venv/lib/python3.8/site-packages

RUN pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ notebook
RUN pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ \
    hdbscan \
    polo \
    luigi \
    networkx \
    python-louvain \
    statsmodels

RUN pip install --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index-url https://mirrors.aliyun.com/pypi/simple/ cytograph==0.6.1 && \
    wget http://172.17.0.1:9000/pypi/cytograph/bh_tsne -O /usr/local/bin/bh_tsne && \
    chmod 755 /usr/local/bin/bh_tsne
