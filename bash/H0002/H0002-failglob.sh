#!/usr/bin/env bash
PS4=$'\t'
set -x

shopt -s failglob

echo ?.2
: reached

echo ?.2a; : skipped
echo ?.2b || : skipped
#echo ?.2c : reached # Note: cannot directly combine as (echo ... : reached)

if : if always true ; then
  #echo ?.3a : reached
  echo ?.3b; : skipped
  echo ?.3c
  : skipped
fi

for x in {4..5}; do
  echo ?.$x
  : skipped
done

(
  echo ?.6
  : skipped
)

{
  echo ?.7
  : skipped
}

: $(echo ?.8 || : skipped)

what(){
  echo ?.9
  : skipped
}
what
