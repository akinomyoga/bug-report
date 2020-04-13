#!/usr/bin/env bash
# vim: set noexpandtab tabstop=2:

# Peng Yu
# https://lists.gnu.org/archive/html/help-bash/2020-04/msg00006.html

#set -v
function f {
  cat "$1" | {
    paste /dev/fd/3 "$2" "$3"
  } 3<&0
}
f <(seq 3) <(seq 11 13) <(seq 21 23)

seq 3 | {
  seq 11 13 | {
    seq 21 23 | {
      f /dev/fd/4 /dev/fd/3 /dev/fd/5
    } 5<&0
  } 3<&0
} 4<&0

# 以下の形式を用いれば良い

set -o pipefail

function f2 {
  local fd1
  cat "$1" | {
    paste /dev/fd/$fd1 "$2" "$3"
  } {fd1}<&0
}

seq 3 | {
  seq 11 13 | {
    seq 21 23 | {
      f2 /dev/fd/$fd1 /dev/fd/$fd2 /dev/fd/$fd3
    } {fd3}<&0
  } {fd2}<&0
} {fd1}<&0

# もっと便利な関数を作れるのでは

echo '[pipesubst]'

function pipesubst {
  local __command=$1; shift
  local __index=1
  while (($#)); do
    __command="local fd$__index; $1 | {
      pipe$__index=/dev/fd/\$fd$__index
      $__command
    } {fd$__index}<&0"
    ((__index++))
    shift
  done
  eval "$__command"
}

function f3 {
  local a=$1 b=$2 c=$3
  pipesubst 'paste "$pipe1" "$b" "$c"' \
            'cat "$a"'
}
pipesubst 'f3 "$pipe1" "$pipe2" "$pipe3"' \
          'seq 3' \
          'seq 11 13' \
          'seq 21 23'
