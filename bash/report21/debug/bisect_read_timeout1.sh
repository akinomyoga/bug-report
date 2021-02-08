#!/bin/bash

rm -f a.pipe
mkfifo a.pipe
exec 9<> a.pipe
rm -f a.pipe
for c in {0..3000}; do
  (eval "echo {0..$((c%1000))}" & read -u 9 -t 0.001) >/dev/null
  echo "ok $c"
done
