#!/bin/bash

echo "GNU bash, $BASH_VERSION ($MACHTYPE)"
head -qn1 /etc/*-release 2>/dev/null | sort -u
sed -n 's/model name[[:space:]]*:/CPU:/p' /proc/cpuinfo | head -n1

case ${1:-fifo} in
(fifo)
  # 途中で止まる
  rm -f a.pipe
  mkfifo a.pipe
  exec 9<> a.pipe
  rm -f a.pipe ;;
(procsub)
  # 途中で止まる
  exec 9< <(sleep 60) ;;
(zero)
  # 問題は発生しない
  exec 9< /dev/zero ;;
esac

for c in {0..2000}; do
  (eval "echo {0..$c}" & read -u 9 -t 0.001) >/dev/null
  # (trap 'echo Hello >/dev/tty' ALRM
  #  eval "echo {0..$c}" &
  #  IFS= read -u 9 -t 0.001 -r -N 1) >/dev/null
  # (eval "echo {0..$c}" & read -t 0.01) >/dev/null # for ksh
  printf $'\r\e[Kok %d' "$c"
done
echo
