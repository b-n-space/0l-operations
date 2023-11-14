########## Toolchain (Rust) image ##########
############################################
FROM debian:11 AS toolchain

ARG DEBIAN_FRONTEND=noninteractive

# Add .cargo/bin to PATH
ENV PATH="/root/.cargo/bin:${PATH}"

# Install system prerequisites
RUN apt-get update -y -q && apt-get install -y -q \
  build-essential \
  curl \
  cmake \
  clang \
  git \
  libgmp3-dev \
  libssl-dev \
  llvm \
  lld \
  pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Install Rust
RUN curl https://sh.rustup.rs -sSf | sh -s -- --default-toolchain stable -y

# Install cargo libraries
RUN cargo install toml-cli
RUN cargo install sccache


##########     Source image      ###########
############################################
FROM toolchain as source

# Clone given release tag or branch of this repo
ARG REPO=https://github.com/0LNetworkCommunity/libra.git
ARG BRANCH=main

# Add target binaries to PATH
ENV SOURCE_PATH="/root/libra-framework" \
  PATH="/root/libra-framework/target/release:${PATH}"

WORKDIR /root/libra-framework

# Fixme(nourspace): depending where these tools are hosted, we might not need to pull
RUN echo "Checking out '${BRANCH}' from '${REPO}' ..." \
  && git clone --branch ${BRANCH} --depth 1 ${REPO} ${SOURCE_PATH} \
  && echo "Commit hash: $(git rev-parse HEAD)"


##########     Builder image      ##########
############################################
FROM source as builder

# # Build 0L binaries
# RUN RUSTC_WRAPPER=sccache make bins

# Build the specified Rust packages as release binaries
RUN cargo build --release \
     -p libra \
     -p libra-genesis-tools \
     -p libra-txs \
     -p diem-db-tool


##########   Production image     ##########
############################################
# Todo(nourspace): find a smaller base image
# build the Rust binaries using the x86_64-unknown-linux-musl target instead of the  default
# x86_64-unknown-linux-gnu target, since Alpine Linux uses musl-libc instead of glibc for its C
FROM debian:11-slim AS prod

# We don't persist this env var in production image as we don't have the source files
ARG SOURCE_PATH="/root/libra-framework"

# Add 0L binaries to PATH
ENV PATH="${SOURCE_PATH}/target/release:${PATH}"

# Install system prerequisites
RUN apt-get update && apt-get install -y \
  curl \
  libssl1.1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder
COPY --from=builder [ \
  "${SOURCE_PATH}/target/release/libra", \
  "${SOURCE_PATH}/target/release/libra-genesis-tools", \
  "${SOURCE_PATH}/target/release/libra-txs", \
  "${SOURCE_PATH}/target/release/diem-db-tool", \
  "${SOURCE_PATH}/target/release/" \
]

WORKDIR /root
