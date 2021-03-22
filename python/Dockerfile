FROM cuda:10.2

RUN apt install --no-install-recommends -y python3.8 python3-pip python3.8-dev python3.8-venv && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2

ENV PATH="/opt/venv/bin:$PATH"
RUN python3 -m venv /opt/venv

RUN pip3 install -i https://mirrors.aliyun.com/pypi/simple -U pip && \
    pip3 config set global.index-url https://mirrors.aliyun.com/pypi/simple/ && \
    #pip3 config set global.trusted-host 172.17.0.1 && \
    #pip3 config set global.index-url http://172.17.0.1:9000/pypi/ && \
    #pip3 config set global.extra-index-url https://mirrors.aliyun.com/pypi/simple/ && \
    pip3 install wheel setuptools_scm
