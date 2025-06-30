# Используем официальный образ Rust для сборки
FROM rust:1.70-slim-bullseye AS builder

# Установка зависимостей (добавляем git)
RUN apt-get update && \
    apt-get install -y \
    git \
    build-essential \
    cmake \
    clang \
    libssl-dev \
    protobuf-compiler && \
    rm -rf /var/lib/apt/lists/*

# Клонирование репозитория
RUN git clone https://github.com/anza-xyz/agave.git /agave
WORKDIR /agave

# Сборка релизной версии
RUN cargo build --release

# Финальный образ
FROM debian:11-slim
COPY --from=builder /agave/target/release/solana-validator /usr/local/bin/

# Проверка работоспособности
RUN solana-validator --version

ENTRYPOINT ["solana-validator"]