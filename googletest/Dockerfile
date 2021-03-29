FROM python:3.8-cuda10.2-cmake3.19 as build

RUN wget http://172.17.0.1:3000/gahoo/googletest/archive/release-1.10.0.tar.gz && \
    tar -xf release-1.10.0.tar.gz && \
    mkdir googletest/build && \
    cd googletest/build && \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/googletest/ && \
    make -j 8 && \
    make install googletest && \
    rm -r /googletest /release-1.10.0.tar.gz

FROM python:3.8-cuda10.2

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/googletest/lib/
COPY --from=build /usr/local/googletest/ /usr/local/googletest/
