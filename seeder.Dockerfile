FROM rust:1.75 as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential

# Clone the repository
RUN git clone https://github.com/radiusxyz/seeder

WORKDIR /app/seeder

# Build the binary
RUN cargo build --release

# Use a minimal runtime image
FROM debian:bullseye-slim

WORKDIR /app/seeder

# Install runtime dependencies
RUN apt-get update && apt-get install -y bash ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy built binary and scripts
COPY --from=builder /app/seeder/target/release/seeder /app/seeder/seeder
COPY --from=builder /app/seeder/scripts /app/seeder/scripts

# Make scripts executable
RUN chmod +x /app/seeder/scripts/execute/*.sh /app/seeder/scripts/rpc-call/*.sh

# ✅ Create env.sh from env_example.sh and apply environment variables
RUN cp /app/seeder/scripts/execute/env_example.sh /app/seeder/scripts/execute/env.sh && \
    cp /app/seeder/scripts/rpc-call/env_example.sh /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|SEEDER_INTERNAL_RPC_URL=.*|SEEDER_INTERNAL_RPC_URL=$SEEDER_INTERNAL_RPC_URL|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_PLATFORM=.*|LIVENESS_PLATFORM=$LIVENESS_PLATFORM|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_SERVICE_PROVIDER=.*|LIVENESS_SERVICE_PROVIDER=$LIVENESS_SERVICE_PROVIDER|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_RPC_URL=.*|LIVENESS_RPC_URL=$LIVENESS_RPC_URL|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_WS_URL=.*|LIVENESS_WS_URL=$LIVENESS_WS_URL|" /app/seeder/scripts/rpc-call/env.sh && \
    sed -i "s|LIVENESS_CONTRACT_ADDRESS=.*|LIVENESS_CONTRACT_ADDRESS=$LIVENESS_CONTRACT_ADDRESS|" /app/seeder/scripts/rpc-call/env.sh

# Set environment variables and run initialization
CMD ["/bin/bash", "-c", "./scripts/execute/01_init_seeder.sh" && "./scripts/execute/02_run_seeder.sh && ./scripts/rpc-call/10_initialize.sh"]