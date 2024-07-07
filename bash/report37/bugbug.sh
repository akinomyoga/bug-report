#!/bin/bash

shopt -s extglob

function test1 {
  local v
  printf -v v '%*s' "$1"
  local a=$EPOCHREALTIME
  x=${v//' '?(x)}
  local b=$EPOCHREALTIME
  bc -l <<< "$b-$a"
}

function test2 {
  local v
  printf -v v '%*s' "$1"
  v+=あ
  local a=$EPOCHREALTIME
  x=${v//' '?(x)}
  local b=$EPOCHREALTIME
  bc -l <<< "$b-$a"
}

function test3 {
  local v
  printf -v v '%*s' "$1"
  v+=い
  local a=$EPOCHREALTIME
  x=${v//' '?(α)}
  local b=$EPOCHREALTIME
  bc -l <<< "$b-$a"
}

function testg1 {
  #local v=$(gcc --help); v=${v::$1}
  local v; printf -v v '%*s' "$1"; v=${v//' '/p }
  local a=$EPOCHREALTIME
  x=${v//+([$' \t\n'])}
  local b=$EPOCHREALTIME
  bc -l <<< "$b-$a"
}

# 0.000019 10
# 0.000543 100
# 0.153542 1000
# 1.108378 2000

# #          # 5.1
# test1 10   # .000021
# test1 100  # .000485
# test1 1000 # .116309
# test1 2000 # .789501

# #          # DEV
# test2 10   # .000027
# test2 100  # .000449
# test2 1000 # .033897
# test2 2000 # .143884

# #          # DEV
# test3 10   # .000017
# test3 100  # .000316
# test3 1000 # .032350
# test3 2000 # .141097

#testg1 10
#testg1 100
testg1 200
