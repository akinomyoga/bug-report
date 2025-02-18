#!/usr/bin/env bash

show() {
  printf '%s: ' "$1"
  shift
  [ "$#" -ne 0 ] && printf '<%s>' "$@"
  echo
}

set -- "" "" "" "" ""
show '*' $*
IFS=
show '*' $*
IFS=x
show '*' $*
set -- $*
show '*' $*
set -- $*
show '*' $*
set -- $*
show '*' $*
set -- $*
show '*' $*

set -- "" "" "" "" ""
IFS=$' \t\n'
show '@' $@
IFS=
show '@' $@
IFS=x
show '@' $@
set -- $*
show '@' $@
set -- $*
show '@' $@
set -- $*
show '@' $@
set -- $*
show '@' $@

if ! eval 'a=()' >/dev/null 2>&1; then
  return 0
fi

IFS=$' \t\n'
echo '========'
a=("" "" "" "" "")
show 'a[*]' ${a[*]}
IFS=
show 'a[*]' ${a[*]}
IFS=x
show 'a[*]' ${a[*]}
a=(${a[*]})
show 'a[*]' ${a[*]}
a=(${a[*]})
show 'a[*]' ${a[*]}
a=(${a[*]})
show 'a[*]' ${a[*]}
a=(${a[*]})
show 'a[*]' ${a[*]}
