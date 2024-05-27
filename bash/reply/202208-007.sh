#!/usr/bin/env bash
# https://lists.gnu.org/archive/html/help-bash/2022-08/msg00007.html

function tokenize.1 {
  eval "tokens=($(
    local str=$1
    while
      history -s "$str" &&
        word=$(history -p '!:0' 2>/dev/null) &&
        [[ $word && $str == *"$word"* ]]
    do
      printf '%q\n' "$word"
      str=${str#*"$word"}
    done
  ))"
}

function tokenize.2 {
  eval "$1=($(
    local i=0
    history -s "$2"
    while word=$(history -p '!:'"$i" 2>/dev/null); do
      printf '%q\n' "$word"
      ((i++))
    done
  ))"
}

# usage: tokenize.bobG <arrayVar> <input ...>
function tokenize.bobG {
  local -n arrayRet="$1"; shift
  local input="$*"
  history -s "$input"
  local word i=0
  arrayRet=()
  while word=$(history -p '!:'$i 2>/dev/null); do
    arrayRet+=("$word")
    ((i++))
  done
  history -d 1
}

function test1 {
  tokenize.2 tokens "$1"
  declare -p tokens
}

test1 'echo hello $(ls >/dev/tty) >World'
test1 'echo "hello world"'
test1 '"hello world" "$(date 1>&2)"'
test1 '"hello world" ${a[x]}'
test1 '"hello world" *.txt'
