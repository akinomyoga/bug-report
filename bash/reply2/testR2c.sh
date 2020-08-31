#!/bin/bash

function Dummy() {
  local -n namerefArray="$1"
  local -a -i myArray=("${namerefArray[@]}")
  local -p
}
declare -a -i namerefArray=('1' '2' '3')
Dummy namerefArray

#------------------------------------------------------------------------------

declare -a myArray=('1' '2' '3')
declare -a inputArray=('1' '2' '3' '-1')
declare -a namerefArray=('1' '2' '3' '-2')

function Dummy {
  [[ $1 == inputArray ]] ||
    eval "local -a inputArray=(\"\${$1[@]}\")"
  local -a -i myArray=("${inputArray[@]}")
  declare -p myArray
}
echo A
Dummy myArray

function Dummy {
  [[ $1 == myArray ]] ||
    eval "local -a myArray=(\"\${$1[@]}\")"
  declare -p myArray
}
echo B
Dummy myArray

function Dummy {
  [[ $1 == refArray ]] || local -n refArray=$1
  [[ $1 == inputArray ]] || local -i inputArray=("${refArray[@]}")
  local -ia myArray=("${inputArray[@]}")
  declare -p myArray
}
echo C
Dummy myArray
Dummy inputArray
Dummy namerefArray
