FROM debian:bullseye

RUN apt-get update && \
    apt-get install -y build-essential curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/noip

COPY noip-duc_3.3.0.tar.gz .

RUN tar xzf noip-duc_3.3.0.tar.gz && \
    cd noip-2.1.9-1 && \
    make && \
    make install

CMD ["noip2", "-d"]
