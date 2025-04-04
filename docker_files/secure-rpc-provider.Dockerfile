FROM rust:1.75 as builder

WORKDIR /app

RUN git clone --branch "feat/re-naming" https://github.com/radiusxyz/secure-rpc-provider

WORKDIR /app/secure-rpc-provider

RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev
RUN cargo build --release

FROM ubuntu:22.04

WORKDIR /app/secure-rpc-provider

RUN apt-get update && apt-get install -y curl

COPY --from=builder /app/secure-rpc-provider/scripts /app/secure-rpc-provider/scripts
COPY --from=builder /app/secure-rpc-provider/target/release/secure-rpc /app/secure-rpc-provider/target/release/secure-rpc