#!/bin/bash

rm -f a.pipe
mkfifo a.pipe
exec 9<> a.pipe
rm -f a.pipe
for i in {0..99999}; do
  printf '\r\e[K%d' "$i"
  read -u 9 -t 0.000001
done

# rm -f a.pipe
# mkfifo a.pipe
# exec 9<> a.pipe
# rm -f a.pipe
# for i in {0..99999}; do
#   printf -v timeout "0.%06d" $((1+i%10))
#   printf '\r\e[K%d, %s' "$i" "$timeout"
#   read -u 9 -t "$timeout"
# done
