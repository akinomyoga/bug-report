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

enable -f ./strmatch.so strmatch

check_count=1
yes=$'\e[32myes\e[m'
no=$'\e[31mno\e[m'

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
  printf '#%d: pat=%-16s str=%-16s %s/%s\n' "$((check_count++))" "$1" "$2" "$strmatch" "$expect"
}

echo '--- Can parsing of [...] could go over the end of @()? ---'
# "[=]=]" は POSIX に従って対応しないものとする。
check '[[=]=])A]'    ']'        "$yes"
check '@([[=]=])A])' ']'        "$yes"
check '@([[=]=])A])' 'AA])'     "$no"  # これは明らかな変な振る舞いである。
check '@([[=]=])])'  ']'        "$yes"
check '@([[=]=])])'  ')'        "$yes"
check '@([[=]=])])'  '[[=]=]])' "$no"
check '@([[=]=])'    '[==]'     "$yes"

# → PATSCAN は end で終端位置を受け取っているので変な所まで踏み越えて
# 解析したりする様な事はない。なので問題は起こらない。OK である。逆に
# bracket expression が踏み越えるという事もない。何故ならば / のチェッ
# クを入れたとしても bracket expression は短くなるだけで長くなるという
# 事はないので。

# PATSCAN の解析との一致性についてもう少し真面目に考察しても良いのでは
# ないか。→ PATSCAN は sm_pattern_scan_bracket を使って実装し直す事に
# した。というよりとても簡単な実装になった。

echo '--- Does "/" after "\?" work properly to cancel bracket expressions? ---'
check '[a\b/]' '[ab/]' "$yes"
check '[a\b/]' 'a'     "$no"

echo '--- Skipping of [=x=] is not processed consistently (vs fnmatch) ---'
check '[[=]=]]' ']'     # "$yes"
check '[[=]=]a]' ']'    # "$yes"
check '[a[=]=]]' ']'    # "$yes"
check '[[=]=]a]' 'a'    # "$yes"
check '[a[=]=]]' 'a'    # "$yes"
check '[a[=]=]]' 'a=]]' # "$no"

check '[[.].]]' ']'     # "$yes"
check '[[.].]a]' ']'    # "$yes"
check '[a[.].]]' ']'    # "$yes"
check '[[.].]a]' 'a'    # "$yes"
check '[a[.].]]' 'a'    # "$yes"
check '[a[.].]]' 'a.]]' # "$no"

# If [=bc=] would not be treated as an equivalence class and [=bc= is
# treated as just a set of characters, the next ] will end the current
# bracket expression.  Then, the remaining `a]' and `]' in the
# following examples are considered outside the bracket expressions.
check '[[=bc=]a]'  '=a]'  "$yes"
check '[a[=bc=]]'  'a]'   "$yes"
# If [=bc=] would cause the entire bracket expression invalid, and the
# beginning [ should be matched literally:
check '[[=bc=]a]'  '[=a]' "$no"
check '[a[=bc=]]'  '[a=]' "$no"
# If [=bc=] would still form an equivalence class:
check '[[=bc=]a]'  'a'    "$no"
check '[a[=bc=]]'  'a'    "$no"
check '[[=bc=]a]'  'bc'   "$no"
check '[a[=bc=]]'  'bc'   "$no"
check '[[=bc=]a]'  'b'    "$no"
check '[a[=bc=]]'  'b'    "$no"
check '[[=bc=]a]'  'c'    "$no"
check '[a[=bc=]]'  'c'    "$no"

echo '--- BRACKMATCH: after match vs before match ---'
check '[a[.].]]'  'a' "$yes"
check '[[.].]a]'  'a' "$yes"
check '[a[:xy:]]' 'a' "$yes"
check '[[:xy:]a]' 'a' "$yes"

check '[a[=]=]]'    'a' "$no"
check '[[=]=]a]'    'a' "$no"
check '[a[.[=.]]'   'a' '???'
check '[[.[=.]a]'   'a' '???'
check '[a[.[==].]]' 'a' '???'
check '[[.[==].]a]' 'a' '???'

echo '--- incomplete POSIX brackets after match ---'
check 'x[a[:y]' 'xa' '???'
check 'x[a[.y]' 'xa' '???'
check 'x[a[=y]' 'xa' '???'

echo '--- PARSE_COLLSYM slash ---'
check '[[./.]]' '[[./.]]' "$yes"
check '[[./.]]' '/'       "$no"
