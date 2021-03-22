#set -ex
#
#nvidia-docker build -t cuda:10.2 cuda
#docker build -t python:3.8-cuda10.2 python
#sudo sed '/"registry-mirrors"/i "default-runtime": "nvidia",' -i /etc/docker/daemon.json
#sudo systemctl restart docker
#nvidia-docker build -t python:3.8-cuda10.2-arrow arrow/3.0.0
#nvidia-docker build -t python:3.8-cuda10.2-arrow0.16 arrow/0.16.0
#nvidia-docker build -t python:3.8-cuda10.2-arrow1.0.1 arrow/1.0.1
#sudo sed '/default-runtime/d' -i /etc/docker/daemon.json
#sudo systemctl restart docker
#docker build -t velocyto:0.17.17 velocyto
#docker build -t cytograph:build cytograph
#docker build -t pyscenic:0.11.0 pySCENIC
#nvidia-docker build -t rmm:0.18 rmm/0.18
docker build -t cudf:0.18.1 cudf/0.18.1
