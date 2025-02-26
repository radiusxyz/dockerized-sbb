FROM rust:1.75 as builder

WORKDIR /app

# Clone the repository
RUN git clone https://github.com/radiusxyz/seeder

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
RUN chmod +x /app/seeder/scripts/seeder
RUN chmod +x /app/seeder/target/release/seeder
RUN chmod +x /app/seeder/scripts/execute/*.sh /app/seeder/scripts/rpc-call/*.sh

# ✅ Create env.sh from env_example.sh and update values
RUN cp /app/seeder/scripts/execute/env_example.sh /app/seeder/scripts/execute/env.sh && \
    cp /app/seeder/scripts/rpc-call/env_example.sh /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|SEEDER_EXTERNAL_RPC_URL=.*|SEEDER_EXTERNAL_RPC_URL=$SEEDER_EXTERNAL_RPC_URL|" /app/seeder/scripts/execute/env.sh && \
    sed -i "s|SEEDER_INTERNAL_RPC_URL=.*|SEEDER_INTERNAL_RPC_URL=$SEEDER_INTERNAL_RPC_URL|" /app/seeder/scripts/execute/env.sh && \
    sed -i "s|SEEDER_INTERNAL_RPC_URL=.*|SEEDER_INTERNAL_RPC_URL=$SEEDER_INTERNAL_RPC_URL|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_PLATFORM=.*|LIVENESS_PLATFORM=$LIVENESS_PLATFORM|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_SERVICE_PROVIDER=.*|LIVENESS_SERVICE_PROVIDER=$LIVENESS_SERVICE_PROVIDER|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_RPC_URL=.*|LIVENESS_RPC_URL=$LIVENESS_RPC_URL|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_WS_URL=.*|LIVENESS_WS_URL=$LIVENESS_WS_URL|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_CONTRACT_ADDRESS=.*|LIVENESS_CONTRACT_ADDRESS=$LIVENESS_CONTRACT_ADDRESS|" /app/seeder/scripts/rpc-call/env.sh

# ✅ Correct CMD syntax
CMD ["/bin/bash", "-c", "/app/seeder/scripts/execute/01_init_seeder.sh && /app/seeder/scripts/execute/02_run_seeder.sh && /app/seeder/scripts/rpc-call/10_initialize.sh"]
