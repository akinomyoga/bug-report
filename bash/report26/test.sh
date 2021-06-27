#!/bin/bash

function test1_1 {
  local sep=$1 mod=$3
  local max; printf -v max %06d $(($2-1))
  eval "A=({000000..$max})"
  IFS=$sep eval 'u="${A[*]}"'; time eval "a=\${u$mod}"
}

function test1 {
  local mod=$1
  test1_1 $'\n' 10000 "$mod"
  test1_1 $'\n' 20000 "$mod"
  test1_1 $'\n' 50000 "$mod"
  test1_1 $'\n' 100000 "$mod"
  test1_1 $'\n' 200000 "$mod"
  test1_1 $'\n' 500000 "$mod"
}

TIMEFORMAT='%R %S %U'
test1 '^'
test1 '@U'
test1 '//A'
