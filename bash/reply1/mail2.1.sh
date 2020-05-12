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

function f { echo "$BASHPID"; }

pid=$(f)
echo "command subst  : $BASHPID,$pid"

ble/util/assign pid f
echo "ble/util/assign: $BASHPID,$pid"
