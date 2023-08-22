#!/bin/bash

git submodule update --init --recursive

for fuzzer in libfuzzer libafl_libfuzzer cargo_libafl; do
  pushd "$fuzzer"
  ./run.sh
  popd
done
