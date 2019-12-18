# test case

echo Single x1c
echo
(
  bind '"\x1c":self-insert'
  bind -p | grep '\\C-\\'
  bind -P | grep '\\C-\\'
  bind '"\x1c":"hello"'
  bind -s
  bind -S
  bind -x '"\x1c":echo world'
  bind -X
)
echo

echo Double x1c
echo
(
  bind '"\x1c\x1c":self-insert'
  bind -p | grep '\\C-\\'
  bind -P | grep '\\C-\\'
  bind '"\x1c\x1c":"hello"'
  bind -s
  bind -S
  bind -x '"\x1c\x1c":echo world'
  bind -X
)
echo

echo 'Use C-\'
echo
(
  bind '"\C-\\a":"hello"'
  bind -s
)
