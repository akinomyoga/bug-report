#!/bin/bash

if [[ ${ZSH_VERSION-} ]]; then
  # There seems to be no way to get the path of the current zsh binary

  setopt extendedglob
  shell=zsh

  # setopt kshglob
  # shell=zshk
else
  shopt -s extglob
  shell=${BASH##*/}
fi

source ~/.mwg/src/ble.sh/src/benchmark.sh

function test1 {
  local len=$1 nest=$2

  local target=$(printf "%*s" "$len" b | sed 's/ /x/g')
  local pattern=x i=
  if [[ $shell == zsh ]]; then
    for ((i=0;i<nest;i++)); do
      pattern='('$pattern')#'
    done
  else
    for ((i=0;i<nest;i++)); do
      pattern='*('$pattern')'
    done
  fi
  ble-measure -q "[[ \$target == $pattern ]]"
  echo "$len" "$nsec" "$nest"
}

function run-test1 {
  local outfile=$shell.test1
  [[ -s $outfile ]] && return 0

  local nest len nsec
  for nest in 1 2 3 4 6 8 10; do
    for len in {1..30} 50 {1,2,5}00 {1,2,5}000 {1,2,5}0000 {1,2,5}00000 {1,2,5}000000 {1,2,5}0000000; do
      test1 "$len" "$nest"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

run-test1

function test1rex {
  local len=$1 nest=$2

  local target=$(printf "%*s" "$len" b | sed 's/ /x/g')
  local pattern=x i
  for ((i=0;i<nest;i++)); do
    pattern=$pattern'*'
  done
  ble-measure -q '[[ $target =~ ^$pattern$ ]]'
  echo "$len" "$nsec" "$nest"
}
function run-test1rex {
  local outfile=$shell.test1rex
  [[ -s $outfile ]] && return 0

  local nest len nsec
  for nest in 1 2 3 4 6 8 10; do
    for len in {1..30} 50 {1,2,5}00 {1,2,5}000 {1,2,5}0000 {1,2,5}00000 {1,2,5}000000 {1,2,5}0000000; do
      test1rex "$len" "$nest"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

run-test1rex

function test2 {
  local len=$1 type=$2
  local target=$(printf "%*s" "$len" '' | sed 's/ /x/g')
  if [[ $shell == zsh ]]; then
    case $type in
    (1) ble-measure -q 'ret=${target%%( )##}' ;;
    (2) ble-measure -q 'ret=${target##( )##}' ;;
    esac
  else
    case $type in
    (1) ble-measure -q 'ret=${target%%+( )}' ;;
    (2) ble-measure -q 'ret=${target##+( )}' ;;
    esac
  fi
  echo "$len" "$nsec" "$type"
}

function run-test2 {
  local outfile=$shell.test2
  [[ -s $outfile ]] && return 0

  local len type
  for type in 1 2; do
    for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
      test2 "$len" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

run-test2

# https://lists.gnu.org/archive/html/bug-bash/2022-10/msg00132.html
# https://lists.gnu.org/archive/html/bug-bash/2022-09/msg00008.html
function test3 {
  local nline=$1 type=$2
  local target=$(yes | head -n "$nline") ret
  if [[ $shell == zsh ]]; then
    case $type in
    (1) ble-measure -q "ret=\${target//( )#\$'\n'( )#/\$'\n'}" ;;
    (2) ble-measure -q "ret=\${target//([\$' \t\n'])##/ }" ;;
    esac
  else
    case $type in
    (1) ble-measure -q "ret=\${target//*( )\$'\n'*( )/\$'\n'}" ;;
    (2) ble-measure -q "ret=\${target//+([\$' \t\n'])/ }" ;;
    esac
  fi
  echo "$nline" "$nsec" "$type"
}

function run-test3 {
  local outfile=$shell.test3
  [[ -s $outfile ]] && return 0

  local type nline nsec
  for type in 1 2; do
    for nline in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
      test3 "$nline" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

run-test3

# https://lists.gnu.org/archive/html/bug-bash/2022-10/msg00048.html
function test4 {
  local len=$1
  local target=$(printf '%0*d' "$len" 0)
  if [[ $shell == zsh ]]; then
    ble-measure -q '[[ $target == (0)## ]]'
  else
    ble-measure -q '[[ $target == +(0) ]]'
  fi
  echo "$len" "$nsec"
}

function run-test4 {
  local outfile=$shell.test4
  [[ -s $outfile ]] && return 0

  local len nsec
  for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
    test4 "$len"
    ((nsec>=5*1000**3)) && break
  done > "$outfile"
}

run-test4

# https://stackoverflow.com/q/47080621
function test5 {
  local nline=$1
  local target=$(yes 3.14 | head -n "$nline") ret
  if [[ $shell == zsh ]]; then
    ble-measure -q 'ret=${target//([0-9])##.}'
  else
    ble-measure -q 'ret=${target//+([0-9]).}'
  fi
  echo "$nline" "$nsec"
}

function run-test5 {
  local outfile=$shell.test5
  [[ -s $outfile ]] && return 0

  local len nsec
  for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
    test5 "$len"
    ((nsec>=5*1000**3)) && break
  done > "$outfile"
}

run-test5

# https://lists.gnu.org/archive/html/bug-bash/2021-07/msg00065.html
# https://stackoverflow.com/q/57481631/4908404
function test6 {
  local len=$1 type=$2
  local target=$(printf '%0*d' "$len" 0)
  if [[ $shell == zsh ]]; then
    case $type in
    (1) ble-measure -q '[[ $target == (^x)##y ]]' ;;
    (2) ble-measure -q '[[ $target == (*)#1 ]]' ;;
    esac
  else
    case $type in
    (1) ble-measure -q '[[ $target == +(!(x))y ]]' ;;
    (2) ble-measure -q '[[ $target == *(*)1 ]]' ;;
    esac
  fi
  echo "$len" "$nsec" "$type"
}
function run-test6 {
  local outfile=$shell.test6
  [[ -s $outfile ]] && return 0

  local type len nsec
  for type in 1 2; do
    for len in $(printf '%s\n' {1..10} {12..30..2} 50 {1,2,5}{00,000,0000,00000,000000,0000000} | sort -n); do
      test6 "$len" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}
run-test6

function test6rex {
  local len=$1 type=$2
  local target=$(printf '%0*d' "$len" 0)
  case $type in
  (0) ble-measure -q '[[ $target =~ ^0+$ ]]' ;;
  (1) ble-measure -q '[[ $target =~ ^(|[^x]|...*)+y$ ]]' ;;
  (2) ble-measure -q '[[ $target =~ ^.**1$ ]]' ;;
  esac
  echo "$len" "$nsec" "$type"
}
function run-test6rex {
  local outfile=$shell.test6rex
  [[ -s $outfile ]] && return 0

  local type len nsec
  for type in 0 1 2; do
    for len in $(printf '%s\n' {1..10} {12..30..2} 50 {1,2,5}{00,000,0000,00000,000000,0000000} | sort -n); do
      test6rex "$len" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

run-test6rex

#------------------------------------------------------------------------------

function test7 {
  local len=$1 type=$2
  local target=$(printf '%0*d' "$len" 1)
  case $type in
  (1)    ble-measure -q '[[ $target == hello ]]' ;;
  (1rex) ble-measure -q '[[ $target =~ ^hello$ ]]' ;;
  (2)    ble-measure -q '[[ $target == *a*b*c* ]]' ;;
  (2rex) ble-measure -q '[[ $target =~ ^.*a.*b.*c.*$ ]]' ;;
  (3)    ble-measure -q '[[ $target == 0*0*0*0*0 ]]' ;;
  (3rex) ble-measure -q '[[ $target =~ ^0.*0.*0.*0.*0$ ]]' ;;
  esac
  echo "$len" "$nsec" "$type"
}
function run-test7 {
  local outfile=$shell.test7
  [[ -s $outfile ]] && return 0

  local type len nsec
  for type in {1..3}{,rex}; do
    for len in $(printf '%s\n' {1..10} {12..30..2} 50 {1,2,5}{00,000,0000,00000,000000,0000000} | sort -n); do
      test7 "$len" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

run-test7

function test8 {
  local len=$1 type=$2
  local target=$(printf '%*s' "$len" '') ret
  if [[ $shell == zsh ]]; then
    case $type in
    (1) ble-measure -q 'ret=${target//" "}' ;;
    (2) ble-measure -q 'ret=${target//" "(x|)}' ;;
    esac
  else
    case $type in
    (1) ble-measure -q 'ret=${target//" "}' ;;
    (2) ble-measure -q 'ret=${target//" "?(x)}' ;;
    esac
  fi
  echo "$len" "$nsec" "$type"
}
function run-test8 {
  local outfile=$shell.test8
  [[ -s $outfile ]] && return 0

  local len type nsec
  for type in 1 2; do
    for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
      test8 "$len" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}
run-test8
