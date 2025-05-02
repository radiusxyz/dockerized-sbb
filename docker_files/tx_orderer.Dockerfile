FROM ubuntu:22.04

WORKDIR /app

RUN apt-get update && apt-get install -y curl git

RUN git clone https://github.com/radiusxyz/tx_orderer /app/tx_orderer \
    && cd /app/tx_orderer \
    && git checkout 827fe5df56a06dfa0afb873b1073f592d1e4f29c

COPY ./bin/tx_orderer /app/tx_orderer/target/release/tx_orderer

RUN chmod +x /app/tx_orderer/target/release/tx_orderer || true
RUN find /app/tx_orderer/scripts -type f -name "*.sh" -exec chmod +x {} \; || true
