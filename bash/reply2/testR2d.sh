#!/bin/bash

function Dummy {
  local -n namerefArray="$1"
  local -a -i myArray=("${namerefArray[@]}")
}
myArray1=("$@")
#myArray1=('a[$(echo Gotcha1 >/dev/tty)]')
Dummy 'myArray1'

echo '--- testR2e.sh ---'
function Dummy2 {
  local -n namerefScalar=$1
  local var=$namerefScalar
}
Dummy2 'a[$(echo Gotcha2 >/dev/tty)]'
