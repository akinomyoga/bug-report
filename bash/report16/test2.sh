#!/bin/bash

dir=dict
mkdir -p "$dir"
mkdir -p out

function test2-init-data {
  [[ -s $dir/array ]] && return 0
  printf '%s\n' $(od -A n -t x4 -N 4000000 /dev/urandom) > "$dir/array"
}
test2-init-data

sizes=($(printf '%s\n' {1,2,5}{,0,00,000,0000,00000} 1000000 | sort  -n))
function test2/run-sizes {
  local name=$1 size slash=/
  echo "[$name]"
  for size in "${sizes[@]}"; do
    "$name" "$size"
  done | tee "out/${name//$slash/.}"
}

#------------------------------------------------------------------------------
# 計測1: これはボトルネックが read line だと判明したので駄目

function test2-insert0 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr=()
  head -"$size" "$dir/array" | {
    local time1=$EPOCHREALTIME
    while read -r line; do :; done
    local time2=$EPOCHREALTIME
  }
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}

function test2-insert1 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr=()
  head -"$size" "$dir/array" | {
    local time1=$EPOCHREALTIME
    while read -r line; do
      arr[i++]=$line
    done
    local time2=$EPOCHREALTIME
  }
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}

function test2-insert2 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=() arr2=()
  head -"$size" "$dir/array" | {
    local time1=$EPOCHREALTIME
    while read -r line; do
      arr1[i]=$line
      arr2[i]=$line
      let i++
    done
    local time2=$EPOCHREALTIME
  }
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}

function test2/insert {
  echo '[test2-insert0]'
  for size in "${sizes[@]}"; do
    test2-insert0 "$size"
  done | tee out/test2.insert0

  echo '[test2-insert1]'
  for size in "${sizes[@]}"; do
    test2-insert1 "$size"
  done | tee out/test2.insert1

  echo '[test2-insert2]'
  for size in "${sizes[@]}"; do
    test2-insert2 "$size"
  done | tee out/test2.insert2
}
#test2/insert

#------------------------------------------------------------------------------
# 計測2: これでもボトルネックは読み取りの方の様だ…。配列は高速だ。
#   逆方向の挿入も高速になっている。古い bash では苦手だったはず。
#   と思ったが古い bash は EPOCHREALTIME がない。面倒なので測らない。

function test2/insertB.0 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local time1=$EPOCHREALTIME line
  for line in $(head -"$size" "$dir/array"); do :; done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}

function test2/insertB.1 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr=()
  local time1=$EPOCHREALTIME line i
  for line in $(head -"$size" "$dir/array"); do
    arr[i++]=$line
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
function test2/insertB.2 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=() arr2=()
  local time1=$EPOCHREALTIME line i
  for line in $(head -"$size" "$dir/array"); do
    arr1[i]=$line
    arr2[i]=$line
    ((i++))
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}

# test2/run-sizes test2/insertB.0
# test2/run-sizes test2/insertB.1
# test2/run-sizes test2/insertB.2

function test2/insertC.1 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr=()
  local time1=$EPOCHREALTIME line i=$size
  for line in $(head -"$size" "$dir/array"); do
    arr[--i]=$line
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
function test2/insertC.2 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=() arr2=()
  local time1=$EPOCHREALTIME line i=$size
  for line in $(head -"$size" "$dir/array"); do
    ((i--))
    arr1[i]=$line
    arr2[i]=$line
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
#test2/run-sizes test2/insertC.1
#test2/run-sizes test2/insertC.2

#------------------------------------------------------------------------------
# 計測3: 読み取り。うーん配列のアクセスは全て線形に改良されている気がする。
#   ランダムアクセスに変えても殆ど性能劣化はない。実は実装がまるまる変わった?

function test2/readA.1 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=($(head -"$size" "$dir/array"))
  local -a arr2=("${arr1[@]}")
  local time1=$EPOCHREALTIME i v1 v2
  for ((i=0;i<size;i++)); do
    v1=${arr1[i]}
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
function test2/readA.2 {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=($(head -"$size" "$dir/array"))
  local -a arr2=("${arr1[@]}")
  local time1=$EPOCHREALTIME i v1 v2
  for ((i=0;i<size;i++)); do
    v1=${arr1[i]}
    v2=${arr1[i]}
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
function test2/readA.1r {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=($(head -"$size" "$dir/array"))
  local -a arr2=("${arr1[@]}")
  local time1=$EPOCHREALTIME i v1 v2
  for ((i=size;--i>=0;i)); do
    v1=${arr1[i]}
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
function test2/readA.2r {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=($(head -"$size" "$dir/array"))
  local -a arr2=("${arr1[@]}")
  local time1=$EPOCHREALTIME i v1 v2
  for ((i=size;--i>=0;i)); do
    v1=${arr1[i]}
    v2=${arr2[i]}
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
function test2/readA.1R {
  local size=$1
  shopt -s lastpipe
  local IFS= TMOUT=
  local -a arr1=($(head -"$size" "$dir/array"))
  local -a arr2=("${arr1[@]}")
  local time1=$EPOCHREALTIME i v1 v2
  for ((i=0;i<size;i++)); do
    v1=${arr1[RANDOM%size]}
  done
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "($time2-$time1)")
  printf '%10s %20s\n' "$size" "$elapsed"
}
# test2/run-sizes test2/readA.1
# test2/run-sizes test2/readA.2
# test2/run-sizes test2/readA.1r
# test2/run-sizes test2/readA.2r
# test2/run-sizes test2/readA.1R
