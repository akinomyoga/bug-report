#!/bin/bash
# debugon () {
#     trap 'if (($?)); then echo "$((LINENO-1)): $(sed -n "$((LINENO-1))p" "$0")" ; fi' DEBUG
# }
# debugoff () {
#     trap - DEBUG
# }
# declare -ft debugoff

#debugon

:
! :
echo "$? after bang"
if ((1)); then
  echo "$? after if ((1))"
fi
echo "$? after if ((1)); fi"
if ((0)); then
  echo "$? after if ((0)) (XXX)"
fi
echo "$? after if ((0)) fi"
if ((1)); then
  echo "$? after if ((1))"
else
  echo "$? after if ((1)) else (XXX)"
fi
echo "$? after if ((1)) else fi"
if ((0)); then
  echo "$? after if ((0)) (XXX)"
else
  echo "$? after if ((0)) else (expect: 1)"
fi
echo "$? after if ((0)) else fi"

#debugoff
