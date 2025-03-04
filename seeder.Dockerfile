FROM rust:1.75 as builder

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/gylman/seeder-gylman && mv seeder-gylman seeder

WORKDIR /app/seeder

# Install dependencies
RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev

# Build the binary
RUN cargo build --release

# Use a minimal runtime image
FROM ubuntu:22.04

WORKDIR /app/seeder

# Install dependencies
RUN apt-get update && apt-get install -y curl

# Copy built binary to both scripts and target/release locations
COPY --from=builder /app/seeder/target/release/seeder /app/seeder/scripts/seeder
COPY --from=builder /app/seeder/target/release/seeder /app/seeder/target/release/seeder

# Copy scripts
COPY --from=builder /app/seeder/scripts /app/seeder/scripts

# Ensure binary and scripts are executable
# RUN chmod +x /app/seeder/scripts/seeder
# RUN chmod +x /app/seeder/target/release/seeder
# RUN chmod +x /app/seeder/scripts/execute/*.sh /app/seeder/scripts/rpc-call/*.sh

# ✅ Copy env_example.sh to env.sh, but don't modify it at build time
RUN cp /app/seeder/scripts/execute/env_example.sh /app/seeder/scripts/execute/env.sh
RUN cp /app/seeder/scripts/rpc-call/env_example.sh /app/seeder/scripts/rpc-call/env.sh

# ✅ Correct CMD syntax
# CMD ["/bin/bash", "-c", "/app/seeder/scripts/execute/01_init_seeder.sh && /app/seeder/scripts/execute/02_run_seeder.sh && /app/seeder/scripts/rpc-call/10_initialize.sh"]
