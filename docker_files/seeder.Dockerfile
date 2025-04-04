FROM rust:1.75 as builder

WORKDIR /app

RUN git clone https://github.com/radiusxyz/seeder

WORKDIR /app/seeder

RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev 
RUN cargo build --release

FROM ubuntu:22.04

WORKDIR /app/seeder

RUN apt-get update && apt-get install -y curl

COPY --from=builder /app/seeder/scripts /app/seeder/scripts
COPY --from=builder /app/seeder/target/release/seeder /app/seeder/target/release/seeder