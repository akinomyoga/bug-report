#!/usr/bin/env bash

HISTFILE=H
_test1() { printf '\e7\n\e[J'; declare -p COMP_WORDS; printf '<%s>' "$@"; printf '\e8'; } && complete -F _test1 test1

function setbreak {
  COMP_WORDBREAKS=$1$IFS
}
function fillline {
  READLINE_LINE='test1 a`b'${COMP_WORDBREAKS::1}
  READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\C-t":fillline'
