#!/bin/bash

function unescape-20210313.1 {
  local s=$1 cleanup=
  if ! shopt -q extglob; then
    shopt -s extglob
    cleanup='shopt -u extglob'
  fi

  # これだと \\n -> \zn -> LF になってしまう
  s=${s//@('\\'|'\')/'\z'}
  s=${s//'\zn'/$'\n'}
  s=${s//'\zt'/$'\t'}
  s=${s//'\z'/'\'}
  result=$s

  eval "$cleanup"
}

function unescape-20210313 {
  local s=$1
  s=${s//z/z0}
  s=${s//'\\'/z1}
  s=${s//'\n'/$'\n'}
  s=${s//'\t'/$'\t'}
  s=${s//z1/'\'}
  s=${s//z0/z}
  result=$s
}

function check {
  #echo "${result@Q}"
  if [[ $result != "$1" ]]; then
    cat -A <<< "XXX $result (expected: $1)" >&2
    return 1
  fi
}

unescape-20210313 '\\'; check $'\\'
unescape-20210313 '\n'; check $'\n'
unescape-20210313 '\t'; check $'\t'
unescape-20210313 '\a'; check $'\\a'
unescape-20210313 '\\n'; check '\n'
unescape-20210313 '\m\n\o\\\s\t\u'; check $'\\m\n\\o\\\\s\t\\u'
unescape-20210313 '\\\z'; check '\\z'

function unescape-helpbash202103-47 {
  local s=$1
  s=${s//z/z0}
  s=${s//'\\'/z1}
  s=${s//'\n'/$'\n'}
  s=${s//'\t'/$'\t'}
  s=${s//z1/'\'}
  s=${s//z0/z}
  result=$s
}
unescape-helpbash202103-47 '\\n'; x=$result
declare -p x | cat -v
