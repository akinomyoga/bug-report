function unregister-prompt_command {
  local -a new=() cmd
  for cmd in "${PROMPT_COMMANDS[@]}"; do
    [[ $cmd != "$1" ]] && new+=("$cmd")
  done
  PROMPT_COMMANDS=("${new[@]}")
}
function my-prompt_command {
  echo "$FUNCNAME"
  unregister-prompt_command "$FUNCNAME"
}
PROMPT_COMMANDS+=('echo test1')
PROMPT_COMMANDS+=(my-prompt_command)
PROMPT_COMMANDS+=('echo test2')
