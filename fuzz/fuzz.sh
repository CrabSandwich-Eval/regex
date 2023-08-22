#!/bin/bash

if [ -z ${BENCHMARK+x} ]; then
  echo -e "BENCHMARK variable must be set to the desired fuzzer benchmark"
  exit
fi

if [ "$#" -lt 2 ]; then
  echo -e "Need a fuzzer variant and a core value."
  exit
fi

fuzzer="$1"
core="$2"

time="8h"

if ! [ -z ${FUZZER_DEBUG+x} ]; then
  time="5s"
fi

if [ "$fuzzer" = "libfuzzer" ] || [ "$fuzzer" = "libafl_libfuzzer" ]; then
  taskset -c "$core" timeout -s SIGKILL "$time" "./$BENCHMARK" -fork=1 -timeout=5 -ignore_ooms=1 -ignore_timeouts=1 -ignore_crashes=1 -detect_leaks=0 -artifact_prefix=./artifacts/ ./output ./seeds
  llvm_cov="/root/.rustup/toolchains/nightly-2023-08-14-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-cov"
elif [ "$fuzzer" = "cargo_libafl" ]; then
  taskset -c "$core" timeout -s SIGKILL "$time" "./$BENCHMARK" --cores all --timout 5000 --output ./output --input ./seeds
  llvm_cov="/root/.rustup/toolchains/nightly-2022-07-20-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/bin/llvm-cov"
else
  echo -e "Invalid fuzzer variant; expected one of: libfuzzer, libafl_libfuzzer, cargo_libafl"
  exit
fi

for file in ./output/*
do
        timeout 5s ./$BENCHMARK $file
        if [ $? -eq 124 ]; then
               mv $file ./artifacts/
        fi
done

cargo fuzz coverage "$BENCHMARK" ./output
"$llvm_cov" show "./target/x86_64-unknown-linux-gnu/coverage/x86_64-unknown-linux-gnu/release/$BENCHMARK" --format=html --instr-profile="./coverage/$BENCHMARK/coverage.profdata" -o result/
