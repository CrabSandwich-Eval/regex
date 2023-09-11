FROM ubuntu:22.04
RUN apt update -y && apt upgrade -y

RUN apt install -y build-essential curl wget lsb-release software-properties-common gnupg vim

# Install LLVM
RUN wget https://apt.llvm.org/llvm.sh && chmod +x llvm.sh && ./llvm.sh 15


# Rust
RUN if which rustup; then rustup self uninstall -y; fi && \
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /rustup.sh && \
    sh /rustup.sh --default-toolchain nightly-2022-12-20 -y && \
    . /root/.cargo/env

ENV PATH="/root/.cargo/bin:$PATH"
ENV BENCHMARK="regex"

# For collecting coverage
RUN rustup component add --toolchain nightly-2022-12-20 llvm-tools-preview

# Copy the project
RUN mkdir /work
COPY . /work/regex
WORKDIR /work/regex/fuzz

# Build the fuzzer
RUN cargo install --git https://github.com/CrabSandwich-Eval/cargo-libafl --rev 9c475ed676c71d5d49cc50d5e08943783bdcd513
RUN cargo libafl build
RUN cp ./target/x86_64-unknown-linux-gnu/release/fuzz_regex_match ./regex

# Gather seeds && make corpus dir && make coverage result dir
RUN mkdir seeds && echo a > seeds/a
RUN mkdir output
RUN mkdir result
RUN mkdir artifacts
