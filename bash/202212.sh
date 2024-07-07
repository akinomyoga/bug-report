#!/bin/bash

# 既にある変数を -r にするのは readonly で、また -x にするのは export
# である。これを同時に行おうとして readonly -x や export -r を実行しよ
# うとしてもそれらのオプションは実装されていない。
#
# declare -rx や typeset -rx を実行しようとすると現在のスコープに変数
# が作られてしまい、既存の変数に対して作用できない。declare -grx を実
# 行すると一番外側の変数に対しては動くがローカル変数に対しては動作しな
# い。

shopt -s expand_aliases
Export1 () { typeset -x "$@"; }
alias Export2='typeset -x'
Export3() { declare -gx "$@"; }

Export4() {
  # local -
  # set -k
  # typeset -x "$@"
  local _arg _assigns=
  local -a _newargs=()
  for _arg; do
    if [[ $_arg =~ ^([a-zA-Z_][a-zA-Z_0-9]*)(\+?=.*)?$ ]]; then
      local _rhs
      if [[ ${BASH_REMATCH[2]} ]]; then
        printf -v _rhs '%s%q' "${BASH_REMATCH[2]%%=*}=" "${BASH_REMATCH[2]#*=}"
      else
        _rhs='=$'${BASH_REMATCH[1]}
      fi
      _assigns=$_assigns${BASH_REMATCH[1]}$_rhs' '
      _newargs+=("${BASH_REMATCH[1]}")
    else
      _newargs+=("$_arg")
    fi
  done

  # declare -x だと関数スコープになってしまうし、export だと -r を付加
  # できない。
  #eval "${_assigns}declare -x \"\${_newargs[@]}\""
  #eval "${_assigns}export \"\${_newargs[@]}\""

  # echo "${_assigns}declare -x ${_newargs[@]}"
  # echo "$FUNCNAME($*): foo=${foo-(unset)} (attrs: ${foo@a})"
}

function tester {
  local foo=123

  case $1 in
  (0) export foo ;;
  (1) Export1 -r foo ;;
  (2) Export2 -r foo ;;
  (3) Export3 -r foo ;;
  (4) Export4 -r foo ;;
  esac

  echo "$FUNCNAME($*): foo=${foo-(unset)} (attrs: ${foo@a})"
}

for i in {0..4}; do
  (
    tester "$i"
    echo "global: foo=${foo-(unset)}"
  )
done

# Note: declare -x で propagate した tempenv は結局関数スコープになっ
#   てしまう。export で propagate した tempenv は previous scope の変
#   数になる (本当か/globalではない事を要確認)?
# check.2() {
#   declare -p bar
#   bar=$bar declare -x bar
#   bar=$bar export bar
#   declare -p bar
# }
# check() {
#   local bar=111
#   declare -p bar
#   check.2
#   declare -p bar
# }
# check
