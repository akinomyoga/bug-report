
_echo() { trap 'echo INT:$FUNCNAME; trap - INT; kill -INT $$' INT; for ((i=0;i<1000000;i++)); do true; done; trap - INT; } && compgen -F _echo
