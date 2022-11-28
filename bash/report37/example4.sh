#!/usr/bin/env bash

LC_COLLATE=C

gcc -O2 -xc -o ./fnmatch - <<-EOF
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

gcc -O2 -shared -xc -o ./strmatch.so - <<-EOF
	#define BUILTIN_ENABLED 0x01
	struct word_desc { char* word; int flags; };
	struct word_list { struct word_list* next; struct word_desc* word; };
	struct builtin {
	  const char* name;
	  int (*function)(struct word_list*);
	  int flags;
	  const char** long_doc;
	  const char* short_doc;
	  char* handle;
	};

	/*#include <glob/strmatch.h>*/
	int strmatch(char *pattern, char *string, int flags);
	#define FNM_PATHNAME    (1 << 0)
	#define FNM_NOESCAPE    (1 << 1)
	#define FNM_PERIOD      (1 << 2)
	#define FNM_LEADING_DIR (1 << 3)
	#define FNM_CASEFOLD    (1 << 4)
	#define FNM_EXTMATCH    (1 << 5)
	#define FNM_FIRSTCHAR   (1 << 6)
	#define FNM_DOTDOT      (1 << 7)

	static int strmatch_builtin(struct word_list* list) {
	  char *str, *pat;
	  if (!list || !list->word) return 2;
	  str = list->word->word;
	  if (!list->next || !list->next->word) return 2;
	  pat = list->next->word->word;

	  if (strmatch (pat, str, FNM_PATHNAME | FNM_PERIOD | FNM_EXTMATCH) == 0)
	    return 0;
	  return 1;
	}
	static const char* strmatch_doc[] = { "This is a builtin to test the behavior of strmatch", 0 };
	struct builtin strmatch_struct = { "strmatch", strmatch_builtin, BUILTIN_ENABLED, strmatch_doc, "strmatch string pattern", 0, };
EOF

check_count=1
yes=$(printf '\033[32myes\033[m')
no=$(printf '\033[31mno\033[m')

if [[ ${BASH_VERSION-} ]]; then
  enable -f ./strmatch.so strmatch

  function check {
    # bash impl
    if strmatch "$2" "$1"; then
      local strmatch=$yes
    else
      local strmatch=$no
    fi

    # fnmatch
    local expect=${3-}
    if [[ ! $expect ]]; then
      if ./fnmatch "$2" "$1"; then
        expect=$yes
      else
        expect=$no
      fi
    fi
    printf '#%d: pat=%-20s str=%-16s %s/%s\n' "$((check_count++))" "$1" "$2" "$strmatch" "$expect"
  }
else
  [[ ${ZSH_VERSION-} ]] && setopt kshglob

  function check {
    # bash impl
    if eval "[[ '$2' == $1 ]]"; then
      result=$yes
    else
      result=$no
    fi
    printf '#%d: pat=%-20s str=%-16s %s\n' "$((check_count++))" "$1" "$2" "$result"
  }
fi

if [[ ${BASH_VERSION-} ]]; then
  echo '--- PATSCAN vs BRACKMATCH ---'
  check '@([[.].])A])' ']'        "$yes"
  check '@([[.].])A])' '==]A])'   "$no"
  check '@([[.].])A])' 'AA])'     "$no"
  check '@([[=]=])A])' ']'        "$no"
  check '@([[=]=])A])' '==]A])'   "$yes"
  check '@([[=]=])A])' 'AA])'     "$no"

  echo '--- BRACKMATCH: after match vs before match ---'
  check '[[=]=]ab]'    'a'     "$no"
  check '[[.[=.]ab]'   'a'     "$yes"
  check '[[.[==].]ab]' 'a'     "$yes"
  echo
  check '[a[=]=]b]'    'a'     "$no"
  check '[a[.[=.]b]'   'a'     "$yes"
  check '[a[.[==].]b]' 'a'     "$yes"
  echo
  check '[a[=]=]b]'    'b'     "$no"
  check '[a[=]=]b]'    'a=]b]' "$yes"
  check '[a[.[=.]b]'   'b'     "$yes"
  check '[a[.[=.]b]'   'ab]'   "$no"
  check '[a[.[==].]b]' 'b'     "$yes"
  check '[a[.[==].]b]' 'ab]'   "$no"
fi

echo '--- incomplete POSIX brackets ---'
check 'x[a[:y]' 'x['   '???'
check 'x[a[:y]' 'x:'   '???'
check 'x[a[:y]' 'xy'   '???'
check 'x[a[:y]' 'x[ay' '???'
echo                   
check 'x[a[.y]' 'x['   '???'
check 'x[a[.y]' 'x.'   '???'
check 'x[a[.y]' 'xy'   '???'
check 'x[a[.y]' 'x[ay' '???'
echo                   
check 'x[a[=y]' 'x['   '???'
check 'x[a[=y]' 'x='   '???'
check 'x[a[=y]' 'xy'   '???'
check 'x[a[=y]' 'x[ay' '???'