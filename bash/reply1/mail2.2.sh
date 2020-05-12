#!/bin/bash

_ble_base_run=$(mktemp -d)
trap -- 'rm -rf "$_ble_base_run"' EXIT

_ble_util_assign_base=$_ble_base_run/$$.ble_util_assign.tmp
_ble_util_assign_level=0
function ble/util/assign {
  local _ble_local_tmp=$_ble_util_assign_base.$((_ble_util_assign_level++))
  builtin eval "$2" >| "$_ble_local_tmp"
  local _ble_local_ret=$? _ble_local_arr=
  ((_ble_util_assign_level--))
  mapfile -t _ble_local_arr < "$_ble_local_tmp"
  IFS=$'\n' eval "$1=\"\${_ble_local_arr[*]}\""
  return "$_ble_local_ret"
}

function cmd {
  echo this is stderr >&2
  echo this is stdout
}

eval -- "$(
  { stderr=$(
      { stdout=$(cmd); } 2>&1
      declare -p stdout >&3); } 3>&1
  declare -p stderr )"
echo "($stdout)($stderr)"

function upvars {
  while (($#)); do
    unset "$1"
    printf -v "$1" %s "$2"
    shift 2
  done
}
function save-stdout-stdin {
  eval -- "$(
    { printf -v "$2" %s "$(
      { printf -v "$1" %s "$(eval -- "$3")"; } 2>&1
      declare -p "$1" >&3)"; } 3>&1
    declare -p "$2" )"
  upvars "$1" "${!1}" "$2" "${!2}"
}

save-stdout-stdin a b cmd
echo "($a)($b)"

ls -la /dev/fd/0 <<EOF
echo yes
EOF
