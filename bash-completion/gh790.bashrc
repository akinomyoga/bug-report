#!/usr/bin/env bash

HISTFILE=H
source ~/.mwg/src/ble.sh/out/ble.sh -o complete_auto_complete= -o complete_menu_filter=

_test1() { printf '\e7\n\n\e[J'; declare -p COMP_WORDS COMP_CWORD COMP_LINE COMP_POINT; printf '<%s>' "$@"; printf '\e8'; COMPREPLY=(alpha beta gamma); } && complete -F _test1 test1

function setbreak {
  COMP_WORDBREAKS=$1$IFS
}
function fillline {
  READLINE_LINE='test1 a`b'${COMP_WORDBREAKS::1}
  READLINE_POINT=${#READLINE_LINE}
}
bind -x '"\C-t":fillline'
