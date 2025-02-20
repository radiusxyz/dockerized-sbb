FROM rust:1.75 as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential

# Clone the repository
RUN git clone https://github.com/radiusxyz/distributed_key_generation

WORKDIR /app/distributed_key_generation

# Build the binary
RUN cargo build --release

# Use a minimal runtime image
FROM debian:bullseye-slim

WORKDIR /app/distributed_key_generation

# Install runtime dependencies
RUN apt-get update && apt-get install -y bash ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy built binary and scripts
COPY --from=builder /app/distributed_key_generation/target/release/key-generator /app/distributed_key_generation/key-generator
COPY --from=builder /app/distributed_key_generation/scripts /app/distributed_key_generation/scripts

# Make scripts executable
RUN chmod +x /app/distributed_key_generation/scripts/execute/*.sh /app/distributed_key_generation/scripts/rpc-call/*.sh

# ✅ Create env.sh from env_example.sh and apply environment variables
RUN cp /app/distributed_key_generation/scripts/execute/env_example.sh /app/distributed_key_generation/scripts/execute/env.sh && \
    cp /app/distributed_key_generation/scripts/rpc-call/env_example.sh /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_INTERNAL_RPC_URL=.*|KEY_GENERATOR_INTERNAL_RPC_URL=$KEY_GENERATOR_INTERNAL_RPC_URL|" /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_CLUSTER_RPC_URL=.*|KEY_GENERATOR_CLUSTER_RPC_URL=$KEY_GENERATOR_CLUSTER_RPC_URL|" /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=$KEY_GENERATOR_EXTERNAL_RPC_URL|" /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_ADDRESS=.*|KEY_GENERATOR_ADDRESS=$KEY_GENERATOR_ADDRESS|" /app/distributed_key_generation/scripts/rpc-call/env.sh

# Set environment variables and run initialization
CMD ["/bin/bash", "-c", "./scripts/execute/01_init_key_generator.sh" && "./scripts/execute/02_run_key_generator.sh" && "./scripts/rpc-call/10_initialize.sh"]
