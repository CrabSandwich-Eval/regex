#!/bin/bash

docker build . -t regex_cargo_libafl

for i in {0..7}
do
  docker run -t --name regex_cargo_libafl-"$i" -d regex_cargo_libafl "/work/regex/fuzz/fuzz.sh" "cargo_libafl" $i
done

for i in {0..7}
do
  docker wait regex_cargo_libafl-"$i"
done
