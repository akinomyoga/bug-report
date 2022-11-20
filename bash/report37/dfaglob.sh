#!/bin/bash

mkdir -p out

source ~/.mwg/src/ble.sh/src/benchmark.sh

function test1 {
  local len=$1 nest=$2

  local target=$(printf "%*s" "$len" b | sed 's/ /x/g')
  local pattern=x i=
  if [[ $shell == regex ]]; then
    for ((i=0;i<nest;i++)); do
      pattern=$pattern'*'
    done
    ble-measure -q '[[ $target =~ ^$pattern$ ]]'
  elif [[ $shell == zsh ]]; then
    for ((i=0;i<nest;i++)); do
      pattern='('$pattern')#'
    done
    ble-measure -q "[[ \$target == $pattern ]]"
  else
    for ((i=0;i<nest;i++)); do
      pattern='*('$pattern')'
    done
    ble-measure -q "[[ \$target == $pattern ]]"
  fi
  echo "$len" "$nsec" "$nest"
}

function run-test1 {
  local outfile=out/$shell.test1
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

function test2 {
  local len=$1 type=$2
  local target=$(printf "%*s" "$len" '' | sed 's/ /x/g')
  if [[ $shell == regex ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
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
  local outfile=out/$shell.test2
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

# https://lists.gnu.org/archive/html/bug-bash/2022-10/msg00132.html
# https://lists.gnu.org/archive/html/bug-bash/2022-09/msg00008.html
function test3 {
  local nline=$1 type=$2
  local target=$(yes | head -n "$nline") ret
  if [[ $shell == regex ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
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
  local outfile=out/$shell.test3
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

# https://lists.gnu.org/archive/html/bug-bash/2022-10/msg00048.html
function test4 {
  local len=$1
  local target=$(printf '%0*d' "$len" 0)
  if [[ $shell == regex ]]; then
    ble-measure -q '[[ $target =~ ^0+$ ]]'
  elif [[ $shell == zsh ]]; then
    ble-measure -q '[[ $target == (0)## ]]'
  else
    ble-measure -q '[[ $target == +(0) ]]'
  fi
  echo "$len" "$nsec"
}

function run-test4 {
  local outfile=out/$shell.test4
  [[ -s $outfile ]] && return 0

  local len nsec
  for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
    test4 "$len"
    ((nsec>=5*1000**3)) && break
  done > "$outfile"
}

# https://stackoverflow.com/q/47080621
function test5 {
  local nline=$1
  local target=$(yes 3.14 | head -n "$nline") ret
  if [[ $shell == regex ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
    ble-measure -q 'ret=${target//([0-9])##.}'
  else
    ble-measure -q 'ret=${target//+([0-9]).}'
  fi
  echo "$nline" "$nsec"
}

function run-test5 {
  local outfile=out/$shell.test5
  [[ -s $outfile ]] && return 0

  local len nsec
  for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
    test5 "$len"
    ((nsec>=5*1000**3)) && break
  done > "$outfile"
}

# https://lists.gnu.org/archive/html/bug-bash/2021-07/msg00065.html
# https://stackoverflow.com/q/57481631/4908404
function test6 {
  local len=$1 type=$2
  local target=$(printf '%0*d' "$len" 0)
  if [[ $shell == regex ]]; then
    case $type in
    (1) ble-measure -q '[[ $target =~ ^(|[^x]|...*)+y$ ]]' ;;
    (2) ble-measure -q '[[ $target =~ ^.**1$ ]]' ;;
    esac
  elif [[ $shell == zsh ]]; then
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
  local outfile=out/$shell.test6
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

#------------------------------------------------------------------------------

function test7 {
  local len=$1 type=$2
  local target=$(printf '%0*d' "$len" 1)
  if [[ $shell == regex ]]; then
    case $type in
    (1) ble-measure -q '[[ $target =~ ^hello$ ]]' ;;
    (2) ble-measure -q '[[ $target =~ ^.*a.*b.*c.*$ ]]' ;;
    (3) ble-measure -q '[[ $target =~ ^0.*0.*0.*0.*0$ ]]' ;;
    esac
  else
    case $type in
    (1) ble-measure -q '[[ $target == hello ]]' ;;
    (2) ble-measure -q '[[ $target == *a*b*c* ]]' ;;
    (3) ble-measure -q '[[ $target == 0*0*0*0*0 ]]' ;;
    esac
  fi
  echo "$len" "$nsec" "$type"
}
function run-test7 {
  local outfile=out/$shell.test7
  [[ -s $outfile ]] && return 0

  local type len nsec
  for type in 1 2 3; do
    for len in $(printf '%s\n' {1..10} {12..30..2} 50 {1,2,5}{00,000,0000,00000,000000,0000000} | sort -n); do
      test7 "$len" "$type"
      ((nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

function test8 {
  local len=$1 type=$2
  local target=$(printf '%*s' "$len" '') ret
  if [[ $shell == regex ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
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
  local outfile=out/$shell.test8
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

function measure-shell {
  local shell
  if [[ ${ZSH_VERSION-} ]]; then
    # There seems to be no way to get the path of the current zsh binary
    case $1 in
    (zshk)
      setopt kshglob
      shell=zshk ;;
    (*)
      setopt extendedglob
      shell=zsh ;;
    esac
  else
    shopt -s extglob
    shell=${1:-${BASH##*/}}
  fi

  run-test1
  run-test2
  run-test3
  run-test4
  run-test5
  run-test6
  run-test7
  run-test8
}

function main {
  if [[ $1 == all ]]; then
    zsh       "$BASH_SOURCE" zsh
    #zsh      "$BASH_SOURCE" zshk
    ./bash0   "$BASH_SOURCE" bash0
    ./bash2v8 "$BASH_SOURCE" bash2v8
    ./bash2v8 "$BASH_SOURCE" regex
    gnuplot dfaglob.gp
  else
    measure-shell "$@"
  fi
}

main "$@"
