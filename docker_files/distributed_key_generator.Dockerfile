FROM rust:1.75 as builder

WORKDIR /app

RUN git clone https://github.com/radiusxyz/distributed_key_generator

WORKDIR /app/distributed_key_generator

RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev
RUN cargo build --release

FROM ubuntu:22.04

WORKDIR /app/distributed_key_generator

RUN apt-get update && apt-get install -y curl

COPY --from=builder /app/distributed_key_generator/scripts /app/distributed_key_generator/scripts
COPY --from=builder /app/distributed_key_generator/target/release/key-generator /app/distributed_key_generator/target/release/key-generator