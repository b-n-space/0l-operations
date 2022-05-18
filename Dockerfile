########## Toolchain (Rust) image ##########
############################################
FROM ubuntu:20.04 AS toolchain

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
ARG BRANCH=main

# Add target binaries to PATH
ENV SOURCE_PATH="/root/libra" \
  PATH="/root/libra/target/release:${PATH}"

WORKDIR /root/libra

# Fixme(nourspace): depending where these tools are hosted, we might not need to pull
RUN echo "Checking out '${BRANCH}'..." \
  && git clone --branch ${BRANCH} --depth 1 https://github.com/OLSF/libra.git ${SOURCE_PATH} \
  && echo "Commit hash: $(git rev-parse HEAD)"


##########     Builder image      ##########
############################################
FROM source as builder

# Build 0L binaries
RUN RUSTC_WRAPPER=sccache make bins


##########   Production image     ##########
############################################
# Todo(nourspace): find a smaller base image
FROM ubuntu:20.04 AS prod

# We don't persist this env var in production image as we don't have the source files
ARG SOURCE_PATH="/root/libra"

# Add 0L binaries to PATH
ENV PATH="${SOURCE_PATH}/target/release:${PATH}"

# Install system prerequisites
RUN apt-get update && apt-get install -y \
  curl \
  libssl1.1 \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy binaries from builder
COPY --from=builder [ \
  "${SOURCE_PATH}/target/release/tower", \
  "${SOURCE_PATH}/target/release/diem-node", \
  "${SOURCE_PATH}/target/release/db-restore", \
  "${SOURCE_PATH}/target/release/db-backup", \
  "${SOURCE_PATH}/target/release/db-backup-verify", \
  "${SOURCE_PATH}/target/release/ol", \
  "${SOURCE_PATH}/target/release/txs", \
  "${SOURCE_PATH}/target/release/onboard", \
  "${SOURCE_PATH}/target/release/" \
]

WORKDIR /root/.0L
