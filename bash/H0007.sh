#!/usr/bin/env bash

# Parameters

# enabled measurements
opts=greg:lea:mike:brace:arith

output_file=

#------------------------------------------------------------------------------

source ~/.mwg/src/ble.sh/src/benchmark.sh

function measure.1 {
  local func=$1 text=$2
  local ret nsec
  ble-measure -c 5 "$func $text"
  [[ $output_file ]] &&
    echo "${#text} $func $nsec" >> "$output_file"
}

function measure-all {
  local text=$1

  # f0() { local arr; }
  # measure.1 f0 "$text"

  if [[ :$opts: == *:greg:* ]]; then
    # L A Walsh
    f1() { local x n="$1" arr; for x in 0 1 2 3 4 5 6 7 8 9; do n=${n//$x/$x }; done; arr=($n); }
    f2() { local i n="${#1}" arr; for ((i=0; i<n; i++)); do arr+=("${1:i:1}"); done; }
    # Greg Wooledge
    f3() { local n="$1" tmp arr i; while ((n > 0)); do tmp+=("$((n%10))"); ((n /= 10)); done; for ((i=${#tmp[@]}-1; i >= 0; i--)); do arr+=("${tmp[i]}"); done; }
    f4() { local n="$1" i=${#1} arr; while ((n > 0)); do arr[--i]=$((n%10)); ((n /= 10)); done; }
    f5() { local i n=${#1} arr; while ((i < n)); do arr[i]="${1:i:1}"; ((i++)); done; }
    f6() { local i n=${#1} arr; for ((i=0; i<n; i++)); do arr[i]="${1:i:1}"; done; }
    measure.1 f1 "$text"
    measure.1 f2 "$text"
    if [[ :$opts: == *:arith:* ]]; then
      measure.1 f3 "$text"
      measure.1 f4 "$text"
    fi
    measure.1 f5 "$text"
    measure.1 f6 "$text"
  fi

  if [[ :$opts: == *:lea:* ]]; then
    # Lea Gris
    shopt -s extglob
    f7() { local arr; IFS=' ' read -ra arr <<< "${1//?()/ }"; }
    f8() { local arr; IFS= mapfile -s1 -t -d $'\37' arr <<<"${1//?()/$'\37'}"; arr[-1]="${arr[-1]%?}"; }
    measure.1 f7 "$text"
    measure.1 f8 "$text"
  fi

  if [[ :$opts: == *:mike:* ]]; then
    # Mike Jonkmans
    f12() { local arr; [[ "$1" =~ ${1//?/(.)} ]]; arr=( "${BASH_REMATCH[@]:1}" ); }
    measure.1 f12 "$text"
  fi

  if [[ :$opts: == *:brace:* ]]; then
    f20() { local i arr; eval "for i in {0..$((${#1}-1))}; do arr[i]=\${1:i:1}; done"; }
    f21() { local arr; eval "arr=('\${1:'{0..$((${#1}-1))}':1}')"; arr=("${arr[@]@P}"); }
    f21b() { local -a "arr=('\${1:'{0..$((${#1}-1))}':1}')"; arr=("${arr[@]@P}"); }
    f22() { local arr; eval "arr=('\"\${1:'{0..$((${#1}-1))}':1}\"')"; local "arr=(${arr[*]})"; }
    f23() { local arr; eval "arr=('\"\${1:'{0..$((${#1}-1))}':1}\"')"; eval "arr=(${arr[*]})"; }
    f24() { local -a "arr=('\"\${1:'{0..$((${#1}-1))}':1}\"')"; local -a "arr=(${arr[*]})"; }
    measure.1 f20 "$text"
    measure.1 f21 "$text"
    measure.1 f21b "$text"
    measure.1 f22 "$text"
    measure.1 f23 "$text"
    measure.1 f24 "$text"
  fi

  if [[ :$opts: == *:arith:* ]]; then
    f30() { local i arr; eval "let i={1..${#1}}-1,'arr[i]=$1/10**i%10'"; }
    #f31() { local arr; local v=$1 i=0 x='v>10?i++,x,i--:(arr[i]=v%10,v/=10)'; : $((x)); declare -p arr; }
    f31() { local arr i=${#1} v=$1 x='arr[--i]=v%10,v/=10,i&&x'; : $((x)); }
    measure.1 f30 "$text"
    measure.1 f31 "$text"
  fi
}

#measure-all 682390
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

#measure-all 9223372036854775807
# NAME ARG  bash-5.0           bash-5.1           bash-dev
# ---- ---  -----------------  -----------------  -----------------
# f1   *N    44.935 usec/eval   47.373 usec/eval   47.694 usec/eval
# f2   *A   117.765 usec/eval  110.829 usec/eval  112.467 usec/eval
# f3   *N   218.435 usec/eval  208.938 usec/eval  210.873 usec/eval
# f4   *N   105.815 usec/eval  106.998 usec/eval  106.042 usec/eval
# f5   *A   112.499 usec/eval  115.269 usec/eval  116.066 usec/eval
# f6   *A   102.330 usec/eval  104.512 usec/eval  106.442 usec/eval
# f7   *B    47.856 usec/eval   54.459 usec/eval   55.903 usec/eval
# f8   *R    69.606 usec/eval   60.349 usec/eval   60.250 usec/eval
# f12  *A    56.081 usec/eval   57.088 usec/eval   57.930 usec/eval
# f20  *A    82.260 usec/eval   84.660 usec/eval   85.648 usec/eval
# f21  *A    68.165 usec/eval   66.532 usec/eval   68.023 usec/eval
# f21b *A    61.962 usec/eval   59.633 usec/eval   61.553 usec/eval
# f22  *A    80.121 usec/eval   74.776 usec/eval   77.130 usec/eval
# f23  *A    95.685 usec/eval   84.609 usec/eval   86.396 usec/eval
# f24  *A    73.762 usec/eval   68.606 usec/eval   71.041 usec/eval
# f30  *N    62.949 usec/eval   61.437 usec/eval   62.290 usec/eval
# f31  *N    54.739 usec/eval   53.150 usec/eval   53.806 usec/eval

#measure-all 1000000000000066600000000000001
# NAME ARG  bash-5.0           bash-5.1           bash-dev
# ---- ---  -----------------  -----------------  -----------------
# f1   *N    49.742 usec/eval   51.704 usec/eval   52.018 usec/eval
# f2   *A   183.606 usec/eval  173.303 usec/eval  176.890 usec/eval
# f3   *N   217.838 usec/eval  209.177 usec/eval  210.466 usec/eval
# f4   *N   106.343 usec/eval  105.500 usec/eval  106.013 usec/eval
# f5   *A   177.746 usec/eval  179.855 usec/eval  180.363 usec/eval
# f6   *A   161.835 usec/eval  163.545 usec/eval  162.796 usec/eval
# f7   *B    69.921 usec/eval   86.118 usec/eval   92.826 usec/eval
# f8   *R   101.589 usec/eval   90.943 usec/eval   96.090 usec/eval
# f12  *A    79.627 usec/eval   82.270 usec/eval   82.882 usec/eval
# f20  *A   123.419 usec/eval  128.211 usec/eval  128.043 usec/eval
# f21  *A    97.537 usec/eval   93.592 usec/eval   94.835 usec/eval
# f21b *A    90.787 usec/eval   87.356 usec/eval   89.171 usec/eval
# f22  *A   117.057 usec/eval  107.285 usec/eval  109.169 usec/eval
# f23  *A   139.168 usec/eval  121.602 usec/eval  122.759 usec/eval
# f24  *A   109.360 usec/eval  100.964 usec/eval  103.422 usec/eval
# f30  *N    95.184 usec/eval   93.001 usec/eval   94.035 usec/eval
# f31  *N    79.010 usec/eval   77.332 usec/eval   78.453 usec/eval

# NAME ARG  bash-5.0           bash-5.1           bash-dev
# ---- ---  -----------------  -----------------  -----------------
# f1   *N    49.742 usec/eval   51.704 usec/eval   52.018 usec/eval
# f2   *A   183.606 usec/eval  173.303 usec/eval  176.890 usec/eval
# f5   *A   177.746 usec/eval  179.855 usec/eval  180.363 usec/eval
# f6   *A   161.835 usec/eval  163.545 usec/eval  162.796 usec/eval
# f7   *B    69.921 usec/eval   86.118 usec/eval   92.826 usec/eval
# f8   *R   101.589 usec/eval   90.943 usec/eval   96.090 usec/eval
# f12  *A    79.627 usec/eval   82.270 usec/eval   82.882 usec/eval
# f20  *A   123.419 usec/eval  128.211 usec/eval  128.043 usec/eval
# f21  *A    97.537 usec/eval   93.592 usec/eval   94.835 usec/eval
# f21b *A    90.787 usec/eval   87.356 usec/eval   89.171 usec/eval
# f22  *A   117.057 usec/eval  107.285 usec/eval  109.169 usec/eval
# f23  *A   139.168 usec/eval  121.602 usec/eval  122.759 usec/eval
# f24  *A   109.360 usec/eval  100.964 usec/eval  103.422 usec/eval

# output_file=H0007-complexity.txt
# : > "$output_file"
# opts=greg:lea:mike:brace:arith
# t100=1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
# measure-all 1
# measure-all 12
# measure-all 12345
# measure-all 1234512345
# measure-all 123451234512345
# opts=greg:lea:mike:brace
# measure-all 12345678901234567890
# measure-all 12345678901234567890123456789012345678901234567890
# measure-all "$t100"
# measure-all "$t100$t100"
# measure-all "$t100$t100$t100$t100$t100"
# measure-all "$t100$t100$t100$t100$t100$t100$t100$t100$t100$t100"
