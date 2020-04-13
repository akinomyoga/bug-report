#!/bin/bash

# tee | sponge f1 | sponge f2

#tee >(sponge f1) >(sponge f2)

sponge() { cat > "$1.txt"; true; }

# set -o pipefail
# {
#   {
#     {
#       tee /dev/fd/$fd1 /dev/fd/$fd2 >&$stdout
#     } {fd1}>&1 | sponge f1
#   } {fd2}>&1 | sponge f2
# } {stdout}>&1

source pipesubst.sh
set -o pipefail
echo hello | \
  pipesubst 'cat "$pipe3"; tee "$pipe1" "$pipe2"' \
            '> sponge f1' \
            '> sponge f2' \
            '< seq 5' | \
  cat > f3.txt
