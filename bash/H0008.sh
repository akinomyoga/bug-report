#!/bin/bash

_rl_ps1_final() {
  printf '%(%T)T '

  # adjust the cursor position to avoid redundant empty lines in corner cases
  ((BASH_VERSINFO[0] >= 5)) || local LC_ALL= LC_CTYPE=C
  READLINE_POINT=${#READLINE_LINE}
}

_rl_ps1_final_initialize() {
  local keymap
  for keymap in emacs vi-insert vi-command; do
    bind -m "$keymap" -x '"\xC0\a": _rl_ps1_final'

    # \r (RET, C-m), \n (C-j)
    bind -m "$keymap" '"\xC0\r": accept-line'
    bind -m "$keymap" '"\r": "\xC0\a\xC0\r"'
    bind -m "$keymap" '"\n":"\xC0\a\xC0\r"'
  done

  # C-o (emacs)
  bind -m emacs '"\xC0\C-o": operate-and-get-next'
  bind -m emacs '"\C-o": "\xC0\a\xC0\C-o"'

  # C-x C-e (emacs)
  bind -m emacs '"\xC0\C-e": edit-and-execute-command'
  bind -m emacs '"\C-x\C-e": "\xC0\a\xC0\C-e"'

  # v (vi-command) ???how to bind to `vi_edit_and_execute_command'???
  # Note: One needs to properly set up VISUAL or EDITOR to "vi", etc.
  bind -m vi-command '"\xC0\C-e": edit-and-execute-command'
  bind -m vi-command '"\C-x\C-e": "\xC0\a\xC0\C-e"'
}
_rl_ps1_final_initialize
unset -f _rl_ps1_final_initialize
