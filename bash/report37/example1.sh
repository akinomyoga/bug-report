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

check_count=1

mkdir -p ab/cd/efg
check_target=ab/cd/efg
check_glob='*/*/efg*'
function check {
  local GLOBIGNORE=$1

  # bash impl
  local -a f=($check_glob)
  if [[ $f == "$check_glob" ]]; then
    local strmatch=$'\e[32myes\e[m'
  else
    local strmatch=$'\e[31mno\e[m'
  fi

  # Linux fnmatch
  if ./fnmatch "$check_target" "$1"; then
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


# Note: GLOBIGNORE は FNM_PERIOD を指定していないので上記の GLOBIGNORE
# を用いた check は FNM_PERIOD の振る舞いに対しては再利用できない。
echo '[tests against ab/.ext]'
touch ab/.ext
check_target=ab/.ext
check_glob=ab/.ex?

function checkpath {
  # bash impl
  if local -a f=($1); [[ $f == "$check_target" ]]; then
    local strmatch=$'\e[32myes\e[m'
  else
    local strmatch=$'\e[31mno\e[m'
  fi

  # Linux fnmatch
  if ./fnmatch "$check_target" "$1"; then
    local fnmatch=$'\e[32myes\e[m'
  else
    local fnmatch=$'\e[31mno\e[m'
  fi
  printf '#%d: pat=%-16s %s/%s\n' "$((check_count++))" "$1" "$strmatch" "$fnmatch"
}

checkpath 'ab/.ext'
checkpath 'ab/*.ext'
checkpath 'ab/@(*.ext)'

enable -f ./strmatch.so strmatch

function checkdot {
  # bash impl

  # if local -a f=($1); [[ $f == "$check_target" ]]; then
  if strmatch "$1" "$2"; then
    local strmatch=$'\e[32myes\e[m'
  else
    local strmatch=$'\e[31mno\e[m'
  fi

  # Linux fnmatch
  if ./fnmatch "$1" "$2"; then
    local fnmatch=$'\e[32myes\e[m'
  else
    local fnmatch=$'\e[31mno\e[m'
  fi
  printf '#%d: str=%-16s pat=%-16s %s/%s\n' "$((check_count++))" "$1" "$2" "$strmatch" "$fnmatch"
}

checkdot ab/.ext 'ab/.*'
checkdot ab/.ext 'ab/*.ext'
checkdot ab/.ext 'ab/@(.ext)'
checkdot ab/.ext 'ab/@(*.ext)'
checkdot ab/.ext '@(ab/.ext)'
checkdot ab/.ext '@(ab/*.ext)'
checkdot ab/.ext 'ab/!(x)'

echo '[Does extglob dot?]'
checkdot .ext    '*.ext'
checkdot .ext    '@(*.ext)'
checkdot ab/.ext 'ab/*.ext'
checkdot ab/.ext 'ab/@(*.ext)'
echo '[Does !(...) match dot and slash?]'
checkdot .ext    '!(x)'
checkdot ab/.ext 'ab/!(x)'
checkdot ab/.ext '!(x)'
checkdot /bin    '!(x)'
checkdot a/b/c   '!(x)'
echo '[Check behavior of [/]]'
checkdot 'ab[/]ef'     'ab[/]ef'
checkdot 'ab[c/d]ef'   'ab[c/d]ef'
checkdot 'ab[.-/]ef'   'ab[.-/]ef'
checkdot 'ab[[=/=]]ef' 'ab[[=/=]]ef'
checkdot 'ab[/c]ef'    'ab[/[abc]]ef'
checkdot 'ab[c'        'ab[c'
checkdot 'ab[c-'       'ab[c-'
# checkdot ab/cd/efg 'ab/!(xx)/efg'
# checkdot ab/cd/efg '!(x)/efg'
