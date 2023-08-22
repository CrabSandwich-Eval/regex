FROM ubuntu:22.04
RUN apt update -y && apt upgrade -y

RUN apt install -y build-essential curl wget lsb-release software-properties-common gnupg vim

# Install LLVM
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 15


# Rust
RUN if which rustup; then rustup self uninstall -y; fi && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /rustup.sh && \
    sh /rustup.sh --default-toolchain nightly-2023-08-14 -y && \
    . /root/.cargo/env

ENV PATH="/root/.cargo/bin:$PATH"
ENV BENCHMARK="regex"

# For collecting coverage
RUN rustup component add --toolchain nightly-2023-08-14 llvm-tools-preview

# Copy the project
RUN mkdir /work
COPY . /work/regex
WORKDIR /work/regex/fuzz

# Build the fuzzer
RUN cargo install -f cargo-fuzz
RUN cargo fuzz build
RUN cp ./target/x86_64-unknown-linux-gnu/release/fuzz_regex_match ./regex

# Gather seeds && make corpus dir && make coverage result dir
RUN mkdir seeds && echo a > seeds/a
RUN mkdir output
RUN mkdir result
RUN mkdir artifacts
