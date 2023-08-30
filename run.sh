#!/bin/bash

docker build . -t regex_libfuzzer

for i in {0..7}
do
  docker run -t --name regex_libfuzzer-"$i" -d regex_libfuzzer "/work/regex/fuzz/fuzz.sh" "libfuzzer" $i
done

for i in {0..7}
do
  docker wait regex_libfuzzer-"$i"
done
