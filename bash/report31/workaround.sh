#!/bin/bash

function fn_broken {
  result=${result// /$string}
}

# solution 1 (need to write the same parameter expansions twice)
function fn_v1 {
  if shopt -q patsub_replacement 2>/dev/null; then
    shopt -u patsub_replacement
    result=${result// /$string}
    shopt -s patsub_replacement
  else
    result=${result// /$string}
  fi
}

# solution 2
function fn_v2 {
  if shopt -q patsub_replacement 2>/dev/null; then
    shopt -u patsub_replacement
    "$FUNCNAME" "$@"
    local status=$?
    shopt -s patsub_replacement
    return "$status"
  else
    result=${result// /$string}
  fi
}

# solution 3 (there is a fork cost)
function fn_v3 {
  local reset=$(shopt -p patsub_replacement 2>/dev/null)
  shopt -u patsub_replacement 2>/dev/null
  result=${result// /$string}
  eval -- "$reset"
}

# solution 4
function fn_v4 {
  local shopt=$BASHOPTS
  shopt -u patsub_replacement 2>/dev/null
  result=${result// /$string}
  [[ :$shopt: != *:patsub_replacement:* ]] || shopt -s patsub_replacement
}

# solution 5
function fn_v5 {
  local reset=
  if shopt -q patsub_replacement &>/dev/null; then
    shopt -u patsub_replacement
    reset='shopt -s patsub_replacement'
  fi
  result=${result// /$string}
  eval "$reset"
}
