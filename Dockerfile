# Builder stage
FROM rust:1.75-slim-bookworm as builder

# Установка зависимостей
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    cmake \
    clang-16 \
    libssl-dev \
    pkg-config \
    git \
    protobuf-compiler \
    libudev-dev \
    llvm-16 \
    libclang-16-dev \
    clang-tools-16 \
    lld-16 \
    && rm -rf /var/lib/apt/lists/*

# Настройка путей для LLVM
ENV LIBCLANG_PATH=/usr/lib/llvm-16/lib
ENV LLVM_CONFIG_PATH=/usr/lib/llvm-16/bin/llvm-config
ENV PATH="/usr/lib/llvm-16/bin:${PATH}"

# Проверка версий
RUN clang-16 --version && llvm-config-16 --version

# Клонирование репозитория
RUN git clone --recursive https://github.com/anza-xyz/agave.git /agave
WORKDIR /agave

# Сборка с выводом информации
RUN cargo build --release --verbose && \
    ls -la /agave/target/release/

# Проверка существования бинарника
RUN test -f /agave/target/release/solana-validator || \
    { echo "Error: solana-validator not found!"; ls -la /agave/target/release/; exit 1; }

# Runtime stage
FROM debian:bookworm-slim

# Установка runtime зависимостей
RUN apt-get update && \
    apt-get install -y \
    libudev1 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Копирование бинарника
COPY --from=builder /agave/target/release/solana-validator /usr/local/bin/

# Set entrypoint
ENTRYPOINT ["solana-validator"]