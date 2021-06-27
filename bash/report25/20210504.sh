#!/bin/bash

bash0=./bash
bash1=./bash-b196583
bash2=./bash-b196583-mod1-mapfile

function generate {
  #printf '%s:' {000001..000010}
  #printf '%s\n' {000001..000020}
  printf '%s\n' {000001..001000}
}

function test1/1 {
  "$1" -c '
    function callback { read line; echo "callback: $line"; }
    mapfile -C callback -c 100
    # function callback { read -d : line; echo "callback: $line"; }
    # mapfile -d : -C callback -c 1
    # function callback { head -c 7; }
    # mapfile -d : -C callback -c 1
  '
}

function test1 {
  echo 'unbuffered (devel)'
  generate | test1/1 "$bash1"
  echo 'buffered (devel)'
  generate > .tmp; test1/1 "$bash1" < .tmp

  echo 'unbuffered (fix)'
  generate | test1/1 "$bash2"
  echo 'buffered (fix)'
  generate > .tmp; test1/1 "$bash2" < .tmp

  # echo 'unbuffered (now)'
  # generate | test1/1 "$bash0"
  # echo 'buffered (now)'
  # generate > .tmp; test1/1 "$bash0" < .tmp
}


bash -c '
  printf "%s\n" {000001..00020} > tmp
  #function callback { echo "a[$1]=$2"; read -d "" -n 7 line; echo "callback: $line"; }
  #mapfile -C callback -c 1 -t a < tmp

  function callback { echo "mapfile a[$1]=$2; callback: $(stdbuf -oL head -1)"; }
  mapfile -C callback -c 1 -t a < tmp
  
' < tmp
