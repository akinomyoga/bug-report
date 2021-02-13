#!/bin/bash

# 修正後の performance 確認

exec 9< <(while :; do sleep 10; done)

measure() {
  local i
  for ((i=0;i<1000;i++)); do read -u 9 -t 0.000001; done
}

TIMEFORMAT='U:%U S:%S R:%R'
for i in {0..99}; do
  time measure
done
