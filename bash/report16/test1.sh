#!/bin/bash

dictdir=dict
mkdir -p "$dictdir"

table=({A..Z} {a..z} {0..9} + /)
function generate_random {
  local i N=$1
  out=
  for ((i=0;i<N;i++)); do
    out+=${table[RANDOM%64]}
  done
}
function prepare_dictionary_data {
  local i size=$1
  local file=$dictdir/$size
  [[ -s $file ]] && return
  echo "generating dictionary data... (size=$size)" >&2
  for ((i=0;i<size;i++)); do
    generate_random 7; key=$out
    generate_random 10; value=$out
    echo $key $value
  done > "$file"
}
function load_dictionary_data {
  local size=$1 key value
  local -A dict=()
  local time1=$EPOCHREALTIME
  while read -r key value; do
    dict[$key]=$value
  done < "$dictdir/$size"
  local time2=$EPOCHREALTIME
  local elapsed=$(bc -l <<< "1000000*($time2-$time1)")
  echo "$1 $elapsed"
}
function check_dictionary_load {
  local size=$1 key value
  local -A dict=()
  while read -r key value; do
    dict[$key]=$value
  done < "$dictdir/$size"

  for key in "${!dict[@]}"; do
    echo "$key" "${dict[$key]}"
  done | sort | sha256sum
  sort -u "$dictdir/$size" | sha256sum
}

sizes=($(printf '%s\n' {1..9}{00,000,0000,00000} 1000000 | sort -n))
for size in "${sizes[@]}"; do
  prepare_dictionary_data "$size"
done

case $1 in
(debug-rehash)
  echo START
  load_dictionary_data 300000
  echo END ;;

(debug-load)
  echo START
  check_dictionary_load 300000
  echo END ;;

(*)
  {
    echo SIZE ELAPSED
    for size in "${sizes[@]}"; do
      load_dictionary_data "$size"
    done
  } | column -tR 1,2 ;;
esac

