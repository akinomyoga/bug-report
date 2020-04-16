#!/bin/bash

function check_loop_condition {
  if ((index++%10==0)); then
    echo index=$index
    ((index<100))
    return
  fi

  : do something
  return 0
}

function update {
  local index=0
  while check_loop_condition; do :; done
}

trap 'update' USR1
kill -USR1 $$
