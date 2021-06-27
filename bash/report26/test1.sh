#!/bin/bash

source ~/.mwg/src/ble.sh/src/benchmark.sh

function test1 {
  local mod=$2
  eval "A=({00000..$1})"
  IFS=$'\n' eval 'u="${A[*]}"'; ble-measure "a=\${u$mod}"
  IFS=' '   eval 'v="${A[*]}"'; ble-measure "a=\${v$mod}"
  #IFS=x     eval 'w="${A[*]}"'; ble-measure "a=\${w$mod}"
}

# test1 00999 '//A'
# test1 09999 '//A'
# test1 99999 '//A'

# test1 00999 '^^'
# test1 09999 '^^'
# test1 99999 '^^'
# test1 00999 ',,'
# test1 09999 ',,'
# test1 99999 ',,'

# test1 00009 '^'
# test1 00099 '^'
# test1 00999 '^'
# test1 09999 '^'
# test1 99999 '^'

# test1 00009 '@U'
# test1 00099 '@U'
# test1 00999 '@U'
# test1 09999 '@U'
# test1 99999 '@U'

# test1 00009 '//A'
# test1 00099 '//A'
# test1 00999 '//A'
# test1 09999 '//A'
#test1 99999 '//A'

function test2/1 {
  local sep=$1 mod=$3
  local max; printf -v max %06d $(($2-1))
  eval "A=({000000..$max})"
  IFS=$sep eval 'u="${A[*]}"'; ble-measure "a=\${u$mod}"
}

function test2 {
  local mod=$1
  test2/1 $'\n' 100 "$mod"
  test2/1 $'\n' 200 "$mod"
  test2/1 $'\n' 500 "$mod"
  test2/1 $'\n' 1000 "$mod"
  test2/1 $'\n' 2000 "$mod"
  test2/1 $'\n' 5000 "$mod"
  test2/1 $'\n' 10000 "$mod"
  test2/1 $'\n' 20000 "$mod"
  test2/1 $'\n' 50000 "$mod"
  test2/1 $'\n' 100000 "$mod"
  test2/1 $'\n' 200000 "$mod"
  test2/1 $'\n' 500000 "$mod"
}

#test2 '//A'
#test2 '^'
test2 '@U'
