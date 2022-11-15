#!/usr/bin/env bash

# trap-append() {
#   local cmd; eval "cmd=($(trap -p "$2"))"
#   if [[ $cmd ]]; then
#     cmd[2]+=$'\n'$1
#   else
#     cmd=(trap -- "$1" "$2")
#   fi

#   # prevent RETURN from being invoked for "trap-append" itself.
#   if [[ $2 == RETURN ]]; then
#     cmd[2]='if [[ $FUNCNAME != trap-append ]]; then '${cmd[2]}$'\nfi'
#   fi
#   "${cmd[@]}"
# }
# trap-prepend() {
#   local cmd; eval "cmd=($(trap -p "$2"))"
#   if [[ $cmd ]]; then
#     cmd[2]+=$'\n'$1
#   else
#     cmd=(trap -- "$1" "$2")
#   fi

#   # prevent RETURN from being invoked for "trap-prepend" itself.
#   if [[ $2 == RETURN ]]; then
#     cmd[2]='if [[ $FUNCNAME != trap-prepend ]]; then '${cmd[2]}$'\nfi'
#   fi
#   "${cmd[@]}"
# }
# declare -ft trap-append
# declare -ft trap-prepend

# function defer {
#   local command=$1 trap
#   eval "trap=($(trap -p RETURN))"
#   if [[ $trap ]]; then
#     trap[2]=$command$'\n'${trap[2]}
#   else
#     trap=(trap -- "$command" RETURN)
#   fi
#   trap[2]='if [[ $FUNCNAME != defer ]]; then '${trap[2]}$'\ntrap - RETURN\nfi'
#   "${trap[@]}"
# }
# declare -ft defer

function defer {
  local trap
  eval "trap=($(trap -p RETURN))"
  trap -- "
    if [[ \$FUNCNAME != defer ]]; then
      trap - RETURN
      $1
      ${trap[2]-}
    fi" RETURN
}
declare -ft defer

function f1 {
  echo allocA
  defer 'echo freeA'

  echo allocB
  defer 'echo freeB'

  f2
  f2
}

function f2 {
  echo f2

  echo allocC
  defer 'echo freeC'

  echo allocD
  defer 'echo freeD'
}


f1
