#!/usr/bin/env bash

PS4=$'\t'
set -x
readonly sigh=1

sigh=2
: reached

sigh=2a; : skipped
sigh=2b || : skipped
sigh=2c echo reached 2c

if : if always true ; then
  sigh=3a echo reached 3a
  sigh=3b; : skipped
  sigh=3c
  : skipped
fi

for x in {4..5}; do
  sigh=$x
  : skipped
done

(
  sigh=6
  : skipped
)

{
  sigh=7
  : skipped
}

: $(sigh=8 || : skipped)

what(){
  sigh=9
  : skipped
}
what
