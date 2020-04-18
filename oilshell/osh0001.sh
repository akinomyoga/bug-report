#!/bin/bash

#------------------------------------------------------------------------------
# FUNCNAME and ble/array#pop

function check-funcname {
  set1=unset set2=unset
  [[ ${FUNCNAME+set} ]] && set1=set
  [[ ${FUNCNAME[0]+set} ]] && set2=set
  echo "\$FUNCNAME = '$FUNCNAME' ($set1)"
  echo "\${FUNCNAME[0]} = '${FUNCNAME[0]}' ($set2)"
  declare -p FUNCNAME
}
#check-funcname

function check-array-pop {
  function ble/array#pop {
    eval "local i$1=\$((\${#$1[@]}-1))"
    if ((i$1>=0)); then
      eval "ret=\${$1[i$1]}"
      unset -v "$1[i$1]"
    else
      ret=
    fi
  }

  arr=(" a a " " b b " " c c ")
  ble/array#pop
}
#check-array-pop

#------------------------------------------------------------------------------
# test case

# これは問題なかった。BASH_LINENO は呼び出し元の行番号だったのを忘れていた。
function check1 {
  function f1 {
    echo "BASH_SOURCE=(${BASH_SOURCE[*]})"
    echo "BASH_LINENO=(${BASH_LINENO[*]})"
    echo "FUNCNAME=(${FUNCNAME[*]})"
  }
  function f2 { f1; }
  function f3 { f2; }
  function f4 { f3; }
  function f5 { f4; }
  f5
  ( f5 )
}

function check2 {
  function f1() { [[ $1 ]]; }
  f1 '' && echo yes || echo no
  f1 'a' && echo yes || echo no
}

#------------------------------------------------------------------------------
# 26. BUG read -t delim and LF

function check3 {
  # printf '%s\n' hello world > a.tmp
  # local content
  # IFS= read -r -d '' content < a.tmp
  # echo "content=[$content]"
  printf '%s\n' hello world | { read -r -d , line; echo "$line"; }
  printf '%s\n' hello world | { read -r -d '' line; echo "$line"; }
}
#check3

#------------------------------------------------------------------------------
# 26. NYI Dynamic unset

function unlocal { unset "$@"; }
function check4 {
  hello=global

  local hello=local
  echo $hello

  unlocal hello
  echo $hello
}

#------------------------------------------------------------------------------
# 29/30 ${a[@]::}

function check5 {
  # function f1 { eval 'echo "$@"'; }; f1 1 2 3
  # function f1 { eval 'v=("$@" "${v[@]}")'; }; v=(A B C); f1 1 2 3; declare -p v

  a=(x y z); echo "${a[@]::1}"
  #a=(x y z); echo "${a[@]::}"
}

#------------------------------------------------------------------------------

function check6 {
  # # 以下だと再現しない
  # f1() { echo hello; } 2>/dev/null; f1; echo world >&2

  #f1() { : >&30; } 2>/dev/null; f1; echo hello >&2
  #{ : >&30; } 2>/dev/null; echo hello >&2
  : 2>/dev/null >&30; echo hello >&2
}

#------------------------------------------------------------------------------

# echo hello
# trap 'echo hello' HUP
# declare -p _ble_builtin_trap_handlers
# echo hello

