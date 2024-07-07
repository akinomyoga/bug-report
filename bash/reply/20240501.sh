#!/bin/bash

unset -v HISTSIZE

function test-sleep-signaled {
  local shell
  for shell in bash-{3.2,4.4,5.2,5.3-alpha} yash ash dash ksh mksh zsh; do
    echo "==== $shell ===="
    $shell -c '/bin/sleep 10; echo "<jobs>"; jobs; echo "</jobs>"' &
    sleep 1
    kill -s USR1 $(ps | awk '/sleep/{print $1}')
    wait
  done
}

function test-sleep-success {
  local shell
  for shell in bash-{3.2,4.4,5.2,5.3-alpha} yash ash dash ksh mksh zsh; do
    echo "==== $shell ===="
    $shell -c '/bin/sleep 1; echo "<jobs>"; jobs; echo "</jobs>"'
  done
}

test-sleep-success
