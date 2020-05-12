# pipesubst (Bash Utility)
#   2020-04-10 K. Murase <myoga.murase@gmail.com>
#   https://lists.gnu.org/archive/html/help-bash/2020-04/msg00016.html

## usage: pipesubst COMMAND SUBST...
##   SUBST has the form of "> command" or "< command"
function pipesubst {
  local __command; pipesubst__QuoteCommand __command "$1"; shift
  __command+=' <&$__fd0 >&$__fd1'

  local __subst __qsubst __index=1
  for __subst; do
    __command="{ local pipe$__index=/dev/fd/\$fd$__index; $__command; }"
    pipesubst__QuoteCommand __qsubst "${__subst#[<>]}"
    if [[ $__subst == \>* ]]; then
      __command="local fd$__index; $__command {fd$__index}>&1 | $__qsubst"
    else
      __command="local fd$__index; $__qsubst | $__command {fd$__index}<&0"
    fi
    ((__index++))
  done
  local __fd{1,2}; eval -- "$__command" {__fd0}<&0 {__fd1}>&1
}
function pipesubst__QuoteCommand {
  local q=\' Q="'\''"
  printf -v "$1" %s "eval -- '${2//$q/$Q}'"
}
