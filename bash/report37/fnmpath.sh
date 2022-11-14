#!/usr/bin/env bash

shopt -s extglob
LC_COLLATE=C

gcc -O2 -xc -o ./fnmatch - <<EOF
#include <fnmatch.h>
#include <stdlib.h>
#include <stdio.h>

int main(int argc, char **argv) {
  if (2 >= argc) {
    fprintf(stderr, "usage: fnmatch string pattern\n");
    exit(2);
  }

  int flags = FNM_PATHNAME | FNM_PERIOD | FNM_EXTMATCH;
  if (fnmatch(argv[2], argv[1], flags) == 0)
    return 0;
  return 1;
}
EOF

mkdir -p ab/cd/efg
check_count=1
function check {
  local GLOBIGNORE=$1

  # bash impl
  local -a f=(*/*/efg*)
  if [[ $f == '*/*/efg*' ]]; then
    local strmatch=$'\e[32myes\e[m'
  else
    local strmatch=$'\e[31mno\e[m'
  fi

  # Linux fnmatch
  if ./fnmatch ab/cd/efg "$1"; then
    local fnmatch=$'\e[32myes\e[m'
  else
    local fnmatch=$'\e[31mno\e[m'
  fi

  printf '#%d: pat=%-16s %s/%s\n' "$((check_count++))" "$1" "$strmatch" "$fnmatch"
}

check 'ab/cd/efg'
check 'ab[/]cd/efg'
check 'ab[/a]cd/efg'
check 'ab[a/]cd/efg'
check 'ab[!a]cd/efg'
check 'ab[.-0]cd/efg'
check '*/*/efg'
check '*[/]*/efg'
check '*[/a]*/efg'
check '*[a/]*/efg'
check '*[!a]*/efg'
check '*[.-0]*/efg'

# check '*/*/efg'
# check '*[b]/*/efg'
# check '*[ab]/*/efg'
# check '*[ba]/*/efg'
# check '*[!a]/*/efg'
# check '*[a-c]/*/efg'

check 'ab@(/)cd/efg'
check '*@(/)cd/efg'
check '*/cd/efg'
