FROM rust:1.75 as builder

WORKDIR /app

RUN git clone https://github.com/gylman/distributed_key_generation-gylman && mv distributed_key_generation-gylman key_generator

WORKDIR /app/key_generator

RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev
RUN cargo build --release

FROM ubuntu:22.04

WORKDIR /app/key_generator

RUN apt-get update && apt-get install -y curl

COPY --from=builder /app/key_generator/scripts /app/key_generator/scripts
COPY --from=builder /app/key_generator/target/release/key-generator /app/key_generator/target/release/key-generator