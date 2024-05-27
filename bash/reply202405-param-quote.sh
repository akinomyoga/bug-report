#!/bin/bash

# https://lists.gnu.org/archive/html/help-bash/2024-05/msg00083.html

shopt -u extquote
bar=expanded
x="${1:-"$bar"}"; declare -p x
x="${1:-'$bar'}"; declare -p x
x="${1:-$'$bar'}"; declare -p x

x="${1:-"foo\ bar"foo\ bar"foo\ bar"}"; echo "#4: $x"

printf '%s\n' "${1:-"foo\ bar"foo\ bar"foo\ bar"}"
