#!/bin/bash

# A=1 builtin eval ':|declare -p A'
# B=1 eval ':|declare -p B'
# C=1 builtin eval 'declare -p C|cat'

# enable builtin

#------------------------------------------------------------------------------

xcmd=':; declare -p A >&2'
arith='a[$('$xcmd')]'
declare -n nref=$arith

A=v01 builtin eval ':; declare -p A'
A=v02 declare -a tmp=([arith]=1)
A=v03 let arith
A=v04 test -v "$arith"
A=v05 [ -v "$arith" ]
A=v06 printf -v "$arith" reply1
(shopt -s cdable_vars; A=v07 cd nref)
A=v08 caller "$arith"
A=v09 compgen -C 'echo $(:; declare -p A >&2)'

x01=1 eval declare -x x01; declare -p x01
x02=2 eval declare -r x02; declare -p x02
x03=3 eval export x03    ; declare -p x03
x04=4 eval readonly x04  ; declare -p x04

#------------------------------------------------------------------------------

echo '========================================'
echo other bugs...

# BUG cdable_vars and nref
(shopt -s cdable_vars; nref=reply1; cd nref; echo "nref=$nref pwd=${PWD##*/}")
# BUG caller [expr]
caller 0+0

# enable .
# enable command

# enable :
# enable alias
# enable bg
# enable bind
# enable break
# enable complete
# enable compopt
# enable continue

# enable dirs
# enable disown
# enable echo
# enable enable
# enable eval
# enable exec
# enable exit
# enable export
# enable false
# enable fc
# enable fg
# enable getopts
# enable hash
# enable help
# enable history
# enable jobs
# enable kill
# enable let
# enable local
# enable logout
# enable mapfile
# enable popd
# enable printf
# enable pushd
# enable pwd
# enable read
# enable readarray
# enable readonly
# enable return
# enable set
# enable shift
# enable shopt
# enable source
# enable suspend
# enable test
# enable times
# enable trap
# enable true
# enable type
# enable typeset
# enable ulimit
# enable umask
# enable unalias
# enable unset
# enable wait
