#!/bin/bash

function unregister-prompt_command.1 {
  local -a new=() cmd
  for cmd in "${PROMPT_COMMAND[@]}"; do
    [[ $cmd != "$1" ]] && new+=("$cmd")
  done
  PROMPT_COMMAND=("${new[@]}")
}
function unregister-prompt_command.2 {
  local i n=${#PROMPT_COMMAND[@]}
  for ((i=0;i<n;i++)); do
    [[ ${PROMPT_COMMAND[i]} == "$1" ]] &&
      PROMPT_COMMAND[i]=
  done
}
function unregister-prompt_command.3 {
  local i n=${#PROMPT_COMMAND[@]}
  for ((i=0;i<n;i++)); do
    [[ ${PROMPT_COMMAND[i]} == "$1" ]] &&
      unset 'PROMPT_COMMAND[i]'
  done
}

function my-prompt_command {
  echo "$FUNCNAME"
  case :$utype: in
  (*:reset:*) unregister-prompt_command.1 "$FUNCNAME" ;;
  (*:empty:*) unregister-prompt_command.2 "$FUNCNAME" ;;
  (*:unset:*) unregister-prompt_command.3 "$FUNCNAME" ;;
  esac

  # random memory operations
  local a
  local -a buff=()
  buff+=('echo AAAAA')
  buff+=('echo 021345678901')
  buff+=('echo 021345678901; echo BBBBB')
  for a in {1..10}; do buff+=(a a+a); done
}

: "${utype:-reset}"

if [[ :$utype: == *:savestring:* ]]; then
  PROMPT_COMMAND+=('echo test1')
  PROMPT_COMMAND+=('my-prompt_command; echo test2')
  PROMPT_COMMAND+=('echo test3')
else
  PROMPT_COMMAND+=('echo test1')
  PROMPT_COMMAND+=(my-prompt_command)
  PROMPT_COMMAND+=('echo test2')
  PROMPT_COMMAND+=('echo test3')
fi

# reset: 後続の PROMPT_COMMAND が実行されない
# empty/unset: こちらは特に何か問題が起こるという訳ではない様だ。

# usage:
#   utype=reset bash --rcfile THISFILE
#   utype=empty bash --rcfile THISFILE
#   utype=unset bash --rcfile THISFILE
#   utype=empty:savestring bash --rcfile THISFILE
#   utype=unset:savestring bash --rcfile THISFILE
