#!/usr/bin/env bash

source ~/.mwg/src/ble.sh/src/benchmark.sh

# f0() { local arr; }
# ble-measure -c 5 'f0 682390'

opts=greg:lea:mike:brace:arith

if [[ :$opts: == *:greg:* ]]; then
  # L A Walsh
  f1() { local x n="$1" arr; for x in 0 1 2 3 4 5 6 7 8 9; do n=${n//$x/$x }; done; arr=($n); }
  f2() { local i n="${#1}" arr; for ((i=0; i<n; i++)); do arr+=("${1:i:1}"); done; }
  # Greg Wooledge
  f3() { local n="$1" tmp arr i; while ((n > 0)); do tmp+=("$((n%10))"); ((n /= 10)); done; for ((i=${#tmp[@]}-1; i >= 0; i--)); do arr+=("${tmp[i]}"); done; }
  f4() { local n="$1" i=${#1} arr; while ((n > 0)); do arr[--i]=$((n%10)); ((n /= 10)); done; }
  f5() { local i n=${#1} arr; while ((i < n)); do arr[i]="${1:i:1}"; ((i++)); done; }
  f6() { local i n=${#1} arr; for ((i=0; i<n; i++)); do arr[i]="${1:i:1}"; done; }
  ble-measure -c 5 'f1 682390'
  ble-measure -c 5 'f2 682390'
  ble-measure -c 5 'f3 682390'
  ble-measure -c 5 'f4 682390'
  ble-measure -c 5 'f5 682390'
  ble-measure -c 5 'f6 682390'
fi

if [[ :$opts: == *:lea:* ]]; then
  # Lea Gris
  shopt -s extglob
  f7() { local arr; IFS=' ' read -ra arr <<< "${1//?()/ }"; }
  f8() { local arr; IFS= mapfile -s1 -t -d $'\37' arr <<<"${1//?()/$'\37'}"; arr[-1]="${arr[-1]%?}"; }
  ble-measure -c 5 'f7 682390'
  ble-measure -c 5 'f8 682390'
fi

if [[ :$opts: == *:mike:* ]]; then
  # Mike Jonkmans
  f12() { local arr; [[ "$1" =~ ${1//?/(.)} ]]; arr=( "${BASH_REMATCH[@]:1}" ); }
  ble-measure -c 5 'f12 682390'
fi

if [[ :$opts: == *:brace:* ]]; then
  f20() { local arr; eval "for i in {0..$((${#1}-1))}; do arr[i]=\${1:i:1}; done"; }
  f21() { local arr; eval "arr=('\${1:'{0..$((${#1}-1))}':1}')"; arr=("${arr[@]@P}"); }
  f21b() { local -a "arr=('\${1:'{0..$((${#1}-1))}':1}')"; arr=("${arr[@]@P}"); }
  f22() { local arr; eval "arr=('\"\${1:'{0..$((${#1}-1))}':1}\"')"; local "arr=(${arr[*]})"; }
  f23() { local arr; eval "arr=('\"\${1:'{0..$((${#1}-1))}':1}\"')"; eval "arr=(${arr[*]})"; }
  f24() { local -a "arr=('\"\${1:'{0..$((${#1}-1))}':1}\"')"; local -a "arr=(${arr[*]})"; }
  ble-measure -c 5 'f20  682390'
  ble-measure -c 5 'f21  682390'
  ble-measure -c 5 'f21b 682390'
  ble-measure -c 5 'f22  682390'
  ble-measure -c 5 'f23  682390'
  ble-measure -c 5 'f24  682390'
fi

if [[ :$opts: == *:arith:* ]]; then
  f30() { local arr; eval "let i={1..${#1}}-1,'arr[i]=$1/10**i%10'"; }
  #f31() { local arr; local v=$1 i=0 x='v>10?i++,x,i--:(arr[i]=v%10,v/=10)'; : $((x)); declare -p arr; }
  f31() { local arr i=${#1} v=$1 x='arr[--i]=v%10,v/=10,i&&x'; : $((x)); }
  ble-measure -c 5 'f30 682390'
  ble-measure -c 5 'f31 682390'
fi

# NAME ARG  bash-5.0          bash-5.1          bash-dev
# ---- ---  ----------------  ----------------  ----------------
# f1   *N   37.633 usec/eval  39.822 usec/eval  39.791 usec/eval
# f2   *A   44.171 usec/eval  42.643 usec/eval  43.752 usec/eval
# f3   *N   79.760 usec/eval  77.892 usec/eval  79.842 usec/eval
# f4   *N   39.870 usec/eval  40.510 usec/eval  40.929 usec/eval
# f5   *A   42.635 usec/eval  43.349 usec/eval  43.617 usec/eval
# f6   *A   39.060 usec/eval  40.191 usec/eval  40.704 usec/eval
# f7   *B   35.110 usec/eval  30.255 usec/eval  31.550 usec/eval
# f8   *R   46.324 usec/eval  36.974 usec/eval  37.672 usec/eval
# f12  *A   30.016 usec/eval  30.566 usec/eval  31.865 usec/eval
# f20  *A   37.930 usec/eval  38.076 usec/eval  38.143 usec/eval
# f21  *A   36.189 usec/eval  34.517 usec/eval  34.967 usec/eval
# f21b *A   29.954 usec/eval  28.655 usec/eval  29.729 usec/eval
# f22  *A   39.251 usec/eval  37.458 usec/eval  38.099 usec/eval
# f23  *A   45.939 usec/eval  42.630 usec/eval  43.187 usec/eval
# f24  *A   33.615 usec/eval  31.600 usec/eval  32.905 usec/eval
# f30  *N   28.908 usec/eval  28.750 usec/eval  28.871 usec/eval
# f31  *N   23.723 usec/eval  23.659 usec/eval  24.366 usec/eval

# The column ARG denotes the accepted type of the argument: *N = only
# numbers are accepted, *A = any characters (except for NUL), *B = any
# non-space characters, *R = any characters except for RS. bash-dev is
# built with "define(relstatus, release)" (configure.ac:27).  The
# times are measured by EPOCHREALTIME.  I have run "fN 682390" for
# 5000 times and obtained the average time of each call.  The whole
# measurements are repeated five times, and the minimal time from the
# five results is picked up for each function and bash version.
