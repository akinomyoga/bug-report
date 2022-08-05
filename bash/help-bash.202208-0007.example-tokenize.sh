#!/bin/bash

HISTFILE=help-bash.202208-0007.example-tokenize.history

function tokenize.1 {
  eval "tokens=($(
    local str=$1
    while [[ $str == *[!$' \t\n']* ]]; do
      history -s "$str"
      word=$(history -p '!:0') || break
      [[ $word ]] || break
      printf '%q\n' "$word"
      [[ $str == *"$word"* ]] || break
      str=${str#*"$word"}
    done
  ))"
}

function tokenize.2 {
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

function tokenize2 {
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

function tokenize { tokenize2 tokens "$@"; }

tokenize 'echo hello $(ls >/dev/tty) >World'
declare -p tokens
tokenize 'echo "hello world"'
declare -p tokens
tokenize '"hello world" "$(date 1>&2)"'
declare -p tokens
tokenize '"hello world" ${a[x]}'
declare -p tokens
tokenize '"hello world" *.txt'
declare -p tokens

history -s A
trap 'history -s B; history' INT
sleep 5
