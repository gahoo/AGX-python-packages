FROM python:3.8-cuda10.2-cmake3.19 as builder

#COPY --from=nccl:2.8.3 /nccl/build/pkg/deb /tmp

RUN apt install -y llvm-7 libopenblas-dev gfortran libjpeg-dev libboost-dev libboost-system-dev libboost-filesystem-dev libboost-dev ocl-icd-opencl-dev swig
#    dpkg -i /tmp/libnccl2_2.8.3-1+cuda10.2_arm64.deb && \ 
#    dpkg -i /tmp/libnccl-dev_2.8.3-1+cuda10.2_arm64.deb

#RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ Cython==0.29.14 llvmlite==0.30.0
RUN git clone http://172.17.0.1:3000/gahoo/h2o4gpu.git && \
    cd h2o4gpu && \
    git checkout rel-0.4.1 && \
    sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' .gitmodules -i && \
    sed 's#gahoo/LightGBM#fork/LightGBM#g' .gitmodules -i && \
    sed 's#gahoo/xgboost#fork/xgboost#g' .gitmodules -i && \
    git submodule update --init && \
    sed 's#https://github.com/.*/#http://172.17.0.1:3000/gahoo/#g' */.gitmodules -i

    #pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index https://mirrors.aliyun.com/pypi/simple numpy==1.18.1 && \
RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ --extra-index https://mirrors.aliyun.com/pypi/simple -r /h2o4gpu/src/interface_py/requirements_buildonly.txt

COPY h2ogpu.patches /tmp/h2ogpu.patches

RUN patch -s -p0 -i /tmp/h2ogpu.patches && \
    #export CMAKE_CUDA_ARCHITECTURES=72 && \
    #export CUDA_ARCHITECTURES=72 && \
    #export GPU_COMPUTE_VER=72 && \
    cd h2o4gpu && \
    make buildinstall

FROM python:3.8-cuda10.2

RUN apt install -y libopenblas-dev ocl-icd-opencl-dev
COPY --from=builder /h2o4gpu/src/interface_py/requirements_runtime.txt /tmp/requirements_runtime.txt
#COPY --from=builder /opt/venv/lib/python3.8/site-packages/ /opt/venv/lib/python3.8/site-packages/

RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ -r /tmp/requirements_runtime.txt numpy==1.18.1
RUN cd /tmp && \
    wget http://172.17.0.1:9000/pypi/lightgbm/lightgbm_cpu-2.2.4-py3-none-any.whl -O lightgbm-2.2.4-py3-none-any.whl && \
    pip install lightgbm-2.2.4-py3-none-any.whl && \
    wget http://172.17.0.1:9000/pypi/lightgbm/lightgbm_gpu-2.2.4-py3-none-any.whl -O lightgbm-2.2.4-py3-none-any.whl && \
    pip install lightgbm-2.2.4-py3-none-any.whl && \
    wget http://172.17.0.1:9000/pypi/xgboost/xgboost-0.90-py3-none-any.whl && \
    pip install xgboost-0.90-py3-none-any.whl && \
    mv /opt/venv/lib/python3.8/site-packages/xgboost /opt/venv/lib/python3.8/site-packages/xgboost_prev && \
    wget http://172.17.0.1:9000/pypi/xgboost/xgboost-1.1.0-cp38-cp38-linux_aarch64.whl && \
    pip install xgboost-1.1.0-cp38-cp38-linux_aarch64.whl && \
    rm /tmp/*.whl
#RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ h2o4gpu==0.21.2 && \
#    mv /opt/venv/lib/python3.8/site-packages/h2o4gpu /opt/venv/lib/python3.8/site-packages/scikit_learn
RUN pip install --no-cache-dir --trusted-host 172.17.0.1 -i http://172.17.0.1:9000/pypi/ h2o4gpu==0.4.1
