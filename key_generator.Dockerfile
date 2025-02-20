FROM rust:1.75 as builder

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y git clang llvm-dev libclang-dev cmake pkg-config build-essential libssl-dev curl

# Clone the repository
RUN git clone https://github.com/radiusxyz/distributed_key_generation

WORKDIR /app/distributed_key_generation

# Build the binary
RUN cargo build --release

# Use a minimal runtime image
FROM ubuntu:22.04

WORKDIR /app/distributed_key_generation

# Copy built binary to the correct location
COPY --from=builder /app/distributed_key_generation/target/release/key-generator /app/distributed_key_generation/scripts/key-generator

# Copy scripts
COPY --from=builder /app/distributed_key_generation/scripts /app/distributed_key_generation/scripts

# Ensure binary and scripts are executable
RUN chmod +x /app/distributed_key_generation/scripts/key-generator
RUN chmod +x /app/distributed_key_generation/scripts/execute/*.sh /app/distributed_key_generation/scripts/rpc-call/*.sh

# ✅ Create env.sh from env_example.sh and update values
RUN cp /app/distributed_key_generation/scripts/execute/env_example.sh /app/distributed_key_generation/scripts/execute/env.sh && \
    cp /app/distributed_key_generation/scripts/rpc-call/env_example.sh /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_INTERNAL_RPC_URL=.*|KEY_GENERATOR_INTERNAL_RPC_URL=$KEY_GENERATOR_INTERNAL_RPC_URL|" /app/distributed_key_generation/scripts/execute/env.sh && \
    sed -i "s|KEY_GENERATOR_CLUSTER_RPC_URL=.*|KEY_GENERATOR_CLUSTER_RPC_URL=$KEY_GENERATOR_CLUSTER_RPC_URL|" /app/distributed_key_generation/scripts/execute/env.sh && \
    sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=$KEY_GENERATOR_EXTERNAL_RPC_URL|" /app/distributed_key_generation/scripts/execute/env.sh && \
    sed -i "s|KEY_GENERATOR_PRIVATE_KEY=.*|KEY_GENERATOR_PRIVATE_KEY=$KEY_GENERATOR_PRIVATE_KEY|" /app/distributed_key_generation/scripts/execute/env.sh && \
    sed -i "s|KEY_GENERATOR_INTERNAL_RPC_URL=.*|KEY_GENERATOR_INTERNAL_RPC_URL=$KEY_GENERATOR_INTERNAL_RPC_URL|" /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_CLUSTER_RPC_URL=.*|KEY_GENERATOR_CLUSTER_RPC_URL=$KEY_GENERATOR_CLUSTER_RPC_URL|" /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_EXTERNAL_RPC_URL=.*|KEY_GENERATOR_EXTERNAL_RPC_URL=$KEY_GENERATOR_EXTERNAL_RPC_URL|" /app/distributed_key_generation/scripts/rpc-call/env.sh && \
    sed -i "s|KEY_GENERATOR_ADDRESS=.*|KEY_GENERATOR_ADDRESS=$KEY_GENERATOR_ADDRESS|" /app/distributed_key_generation/scripts/rpc-call/env.sh

# ✅ Correct CMD syntax
CMD ["/bin/bash", "-c", "/app/distributed_key_generation/scripts/execute/01_init_key_generator.sh && /app/distributed_key_generation/scripts/execute/02_run_key_generator.sh && /app/distributed_key_generation/scripts/rpc-call/10_initialize.sh"]
