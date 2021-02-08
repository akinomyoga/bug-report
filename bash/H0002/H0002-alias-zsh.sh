#!/usr/bin/env zsh

#setopt aliases
alias alias_2='echo alias_2'
alias_2
alias alias_2a='echo alias_2a'; alias_2a
alias alias_2b='echo alias_2b' || alias_2b

if : if always true ; then
  alias alias_3b='echo alias_3b'; alias_3b
  alias alias_3c='echo alias_3c'
  alias_3c
fi

for x in {4..5}; do
  alias alias_4='echo alias_4'
  alias_4
done

(
  alias alias_6='echo alias_6'
  alias_6
)

{
  alias alias_7='echo alias_7'
  alias_7
}

: $(alias alias_8='echo alias_8' || alias_8)

what(){
  alias alias_9='echo alias_9'
  alias_9
}
what
