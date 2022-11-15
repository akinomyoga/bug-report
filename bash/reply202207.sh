

# https://lists.gnu.org/archive/html/help-bash/2022-07/msg00034.html

#bind '"\eOP": "\C-aecho '\''<up>'\'':\C-m"'

# function rl_print_line_and_clear() {
#   printf '\e[34m<up>:\e[0m%s\n' "$READLINE_LINE"
#   READLINE_LINE=
#   READLINE_POINT=0
#   READLINE_MARK=0
# }
# bind -x '"\eOP": rl_print_line_and_clear'

#bind '"\eOP": "\C-aecho \C-v\e[34m'\''<up>'\'':\C-v\e[0m\C-m"'
bind '"\eOP": "\C-aecho \C-v\e[34m'\''<up>'\'':\C-v\e[0m\C-m"'

