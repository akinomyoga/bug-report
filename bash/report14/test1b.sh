bind '"\x1c\x1c":self-insert'
bind -p | grep '\\C-\\'
bind '"\x1c\x1c":"hello"'
bind -s
bind -x '"\x1c\x1c":echo world'
bind -X
exit
