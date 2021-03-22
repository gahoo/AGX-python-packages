FROM velocyto:0.17.17

#RUN apt install bison flex libxml2-dev libgmp-dev unzip && \
RUN apt install -y unzip && pip install uncompyle6

RUN wget http://172.17.0.1:9000/github.com/linnarsson-lab/cytograph2/archive/master.zip && \
    unzip master.zip && rm master.zip && \
    cd cytograph2-master/ && \
    uncompyle6 cytograph/annotation/__pycache__/karyotyper.cpython-37.pyc > cytograph/annotation/karyotyper.py && \
    python setup.py bdist_wheel
    
RUN wget http://172.17.0.1:9000/github.com/linnarsson-lab/cytograph/archive/master.zip && \
    unzip master.zip && rm master.zip && \
    cd cytograph-master/bhtsne && \
    g++ sptree.cpp tsne.cpp -o bh_tsne -O2 && \
    cp bh_tsne /usr/local/bin/ && \
    cd .. && \
    sed 's/lg.DEBUG/lg.WARNING/g' cytograph/utils.py -i && \
    sed 's/from sklearn.externals //g' cytograph/utils.py -i && \
    python setup.py bdist_wheel
    
