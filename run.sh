#!/bin/bash

docker build . -t regex_libafl_libfuzzer

for i in {0..7}
do
  docker run -t --name regex_libafl_libfuzzer-"$i" -d regex_libafl_libfuzzer "/work/regex/fuzz/fuzz.sh" "libafl_libfuzzer" $i
done

for i in {0..7}
do
  docker wait regex_libafl_libfuzzer-"$i"
done

