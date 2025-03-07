FROM rust:1.75 as builder

WORKDIR /app

RUN git clone https://github.com/gylman/tx_orderer

WORKDIR /app/tx_orderer

RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev
RUN cargo build --release

FROM ubuntu:22.04

WORKDIR /app/tx_orderer

RUN apt-get update && apt-get install -y curl

COPY --from=builder /app/tx_orderer/scripts /app/tx_orderer/scripts
COPY --from=builder /app/tx_orderer/target/release/sequencer /app/tx_orderer/target/release/sequencer