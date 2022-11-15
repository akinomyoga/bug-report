#!/bin/bash

function test1 {
  local nr_lines=0
  while read -r _; do
    nr_lines=$(( nr_lines + 1 ))
  done < <(echo a; echo b; echo c; exit 123)

  #   This checks the exit code of the shell running 'echo a; echo b; echo c'
  wait "$!"

  echo "$nr_lines ($?)"
}
#test1

function test2 {
  local nr_lines=0

  local tmp
  tmp=$(mktemp -u)
  mkfifo -m 600 "$tmp"
  trap 'rm "$tmp"' RETURN

  (printf '%s\n' a{1..99}; exit 123) > "$tmp" &
  while read -r _; do
    nr_lines=$(( nr_lines + 1 ))
  done < "$tmp"

  #   This checks the exit code of the shell running 'echo a; echo b; echo c'
  wait "$!"

  echo "$nr_lines ($?)"
}
#test2

tmp=$(mktemp -d)
mkfifo "$tmp/pipe"
trap 'rm -r "$tmp"' EXIT

nr_lines=0
(echo a; echo b; echo c; exit 123) > "$tmp/pipe" &
while read -r _; do
  nr_lines=$(( nr_lines + 1 ))
done < "$tmp/pipe"

# This checks the exit code of the shell running 'echo a; echo b; echo c'
wait "$!"
echo "$nr_lines ($?)"
