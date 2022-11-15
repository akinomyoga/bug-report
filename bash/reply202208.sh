#!/usr/bin/env bash

if [[ $OIL_VERSION ]]; then
  shopt -s eval_unsafe_arith # enable recursive evaluation in osh
fi
export I1=I1=10 I2=5 I3=I2+=1;printf "<$((I1=0?I1:I3))>";echo "<$I1><$I2><$I3>"
export I1=I1=10 I2=5 I3=I2+=1;printf "<$((I1=1?I1:I3))>";echo "<$I1><$I2><$I3>"

# bash, zsh, ksh93, mksh, osh, posh
# busybox
# yash, dash, ash
# tcsh, csh, fish
