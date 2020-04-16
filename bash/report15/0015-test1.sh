#!/bin/bash

function setexit { return "$1"; }

trap 'setexit 123; return' USR1

function loop {
  while :; do :; done
}

function get_loop_exit {
  loop
  echo "loop_exit_status=$?"
}

{ sleep 1; kill -USR1 $$; } &
get_loop_exit
