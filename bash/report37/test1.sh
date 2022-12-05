#!/usr/bin/env bash

LC_COLLATE=C

# [[ ./fnmatch -nt fnmatch.c ]] ||
#   gcc -O2 -o ./fnmatch fnmatch.c

[[ ./strmatch.so -nt strmatch_builtin.c ]] ||
  gcc -O2 -shared -fPIC -o ./strmatch.so strmatch_builtin.c

enable -f ./strmatch.so strmatch

source ~/.mwg/src/ble.sh/out/ble.sh --lib

ble-import lib/core-test

ble/test/start-section 'strmatch (fmatch)' 170

(
  # fixed strings
  ble/test "  strmatch    'hello' 'hello'"
  ble/test "! strmatch    'hello' 'world'"

  ble/test "  strmatch    'abc' 'abc'"
  ble/test "  strmatch -P 'abc' 'abc'"
  ble/test "  strmatch -p 'abc' 'abc'"
  ble/test "  strmatch -S 'abc' 'abc'"
  ble/test "  strmatch -s 'abc' 'abc'"
  ble/test "  strmatch -M 'abc' 'abc'"
  ble/test "  strmatch -m 'abc' 'abc'"

  ble/test "! strmatch    'ab' 'abc'"
  ble/test "  strmatch -P 'ab' 'abc'"
  ble/test "  strmatch -p 'ab' 'abc'"
  ble/test "! strmatch -S 'ab' 'abc'"
  ble/test "! strmatch -s 'ab' 'abc'"
  ble/test "  strmatch -M 'ab' 'abc'"
  ble/test "  strmatch -m 'ab' 'abc'"

  ble/test "! strmatch    'bc' 'abc'"
  ble/test "! strmatch -P 'bc' 'abc'"
  ble/test "! strmatch -p 'bc' 'abc'"
  ble/test "  strmatch -S 'bc' 'abc'"
  ble/test "  strmatch -s 'bc' 'abc'"
  ble/test "  strmatch -M 'bc' 'abc'"
  ble/test "  strmatch -m 'bc' 'abc'"

  ble/test "! strmatch    '' 'abc'"
  ble/test "  strmatch -P '' 'abc'"
  ble/test "  strmatch -p '' 'abc'"
  ble/test "  strmatch -S '' 'abc'"
  ble/test "  strmatch -s '' 'abc'"
  ble/test "  strmatch -M '' 'abc'"
  ble/test "  strmatch -m '' 'abc'"

  ble/test "! strmatch    'b' 'abc'"
  ble/test "! strmatch -P 'b' 'abc'"
  ble/test "! strmatch -p 'b' 'abc'"
  ble/test "! strmatch -S 'b' 'abc'"
  ble/test "! strmatch -s 'b' 'abc'"
  ble/test "  strmatch -M 'b' 'abc'"
  ble/test "  strmatch -m 'b' 'abc'"

  ble/test "! strmatch    'ac' 'abc'"
  ble/test "! strmatch -P 'ac' 'abc'"
  ble/test "! strmatch -p 'ac' 'abc'"
  ble/test "! strmatch -S 'ac' 'abc'"
  ble/test "! strmatch -s 'ac' 'abc'"
  ble/test "! strmatch -M 'ac' 'abc'"
  ble/test "! strmatch -m 'ac' 'abc'"

  # fixed-length pattern (bracket expression)
  ble/test "  strmatch    'a[abc]c' 'abc'"
  ble/test "  strmatch -P 'a[abc]c' 'abc'"
  ble/test "  strmatch -p 'a[abc]c' 'abc'"
  ble/test "  strmatch -S 'a[abc]c' 'abc'"
  ble/test "  strmatch -s 'a[abc]c' 'abc'"
  ble/test "  strmatch -M 'a[abc]c' 'abc'"
  ble/test "  strmatch -m 'a[abc]c' 'abc'"

  ble/test "  strmatch    'a[a-c]c' 'abc'"
  ble/test "  strmatch -P 'a[a-c]c' 'abc'"
  ble/test "  strmatch -p 'a[a-c]c' 'abc'"
  ble/test "  strmatch -S 'a[a-c]c' 'abc'"
  ble/test "  strmatch -s 'a[a-c]c' 'abc'"
  ble/test "  strmatch -M 'a[a-c]c' 'abc'"
  ble/test "  strmatch -m 'a[a-c]c' 'abc'"

  ble/test "  strmatch    'a[!ac]c' 'abc'"
  ble/test "  strmatch -P 'a[!ac]c' 'abc'"
  ble/test "  strmatch -p 'a[!ac]c' 'abc'"
  ble/test "  strmatch -S 'a[!ac]c' 'abc'"
  ble/test "  strmatch -s 'a[!ac]c' 'abc'"
  ble/test "  strmatch -M 'a[!ac]c' 'abc'"
  ble/test "  strmatch -m 'a[!ac]c' 'abc'"

  ble/test "  strmatch    'a[[=b=]]c' 'abc'"
  ble/test "  strmatch -P 'a[[=b=]]c' 'abc'"
  ble/test "  strmatch -p 'a[[=b=]]c' 'abc'"
  ble/test "  strmatch -S 'a[[=b=]]c' 'abc'"
  ble/test "  strmatch -s 'a[[=b=]]c' 'abc'"
  ble/test "  strmatch -M 'a[[=b=]]c' 'abc'"
  ble/test "  strmatch -m 'a[[=b=]]c' 'abc'"

  ble/test "! strmatch    'a[![=b=]]c' 'abc'"
  ble/test "! strmatch -P 'a[![=b=]]c' 'abc'"
  ble/test "! strmatch -p 'a[![=b=]]c' 'abc'"
  ble/test "! strmatch -S 'a[![=b=]]c' 'abc'"
  ble/test "! strmatch -s 'a[![=b=]]c' 'abc'"
  ble/test "! strmatch -M 'a[![=b=]]c' 'abc'"
  ble/test "! strmatch -m 'a[![=b=]]c' 'abc'"

  ble/test "  strmatch    'a[[:alpha:]]c' 'abc'"
  ble/test "  strmatch -P 'a[[:alpha:]]c' 'abc'"
  ble/test "  strmatch -p 'a[[:alpha:]]c' 'abc'"
  ble/test "  strmatch -S 'a[[:alpha:]]c' 'abc'"
  ble/test "  strmatch -s 'a[[:alpha:]]c' 'abc'"
  ble/test "  strmatch -M 'a[[:alpha:]]c' 'abc'"
  ble/test "  strmatch -m 'a[[:alpha:]]c' 'abc'"

  ble/test "! strmatch    'a[![:alpha:]]c' 'abc'"
  ble/test "! strmatch -P 'a[![:alpha:]]c' 'abc'"
  ble/test "! strmatch -p 'a[![:alpha:]]c' 'abc'"
  ble/test "! strmatch -S 'a[![:alpha:]]c' 'abc'"
  ble/test "! strmatch -s 'a[![:alpha:]]c' 'abc'"
  ble/test "! strmatch -M 'a[![:alpha:]]c' 'abc'"
  ble/test "! strmatch -m 'a[![:alpha:]]c' 'abc'"

  ble/test "  strmatch    '[ax]bc' 'abc'"
  ble/test "  strmatch -P '[ax]bc' 'abc'"
  ble/test "  strmatch -p '[ax]bc' 'abc'"
  ble/test "  strmatch -S '[ax]bc' 'abc'"
  ble/test "  strmatch -s '[ax]bc' 'abc'"
  ble/test "  strmatch -M '[ax]bc' 'abc'"
  ble/test "  strmatch -m '[ax]bc' 'abc'"

  ble/test "  strmatch    'ab[cx]' 'abc'"
  ble/test "  strmatch -P 'ab[cx]' 'abc'"
  ble/test "  strmatch -p 'ab[cx]' 'abc'"
  ble/test "  strmatch -S 'ab[cx]' 'abc'"
  ble/test "  strmatch -s 'ab[cx]' 'abc'"
  ble/test "  strmatch -M 'ab[cx]' 'abc'"
  ble/test "  strmatch -m 'ab[cx]' 'abc'"

  ble/test "! strmatch    '[!ax]bc' 'abc'"
  ble/test "! strmatch -P '[!ax]bc' 'abc'"
  ble/test "! strmatch -p '[!ax]bc' 'abc'"
  ble/test "! strmatch -S '[!ax]bc' 'abc'"
  ble/test "! strmatch -s '[!ax]bc' 'abc'"
  ble/test "! strmatch -M '[!ax]bc' 'abc'"
  ble/test "! strmatch -m '[!ax]bc' 'abc'"

  ble/test "! strmatch    'ab[!cx]' 'abc'"
  ble/test "! strmatch -P 'ab[!cx]' 'abc'"
  ble/test "! strmatch -p 'ab[!cx]' 'abc'"
  ble/test "! strmatch -S 'ab[!cx]' 'abc'"
  ble/test "! strmatch -s 'ab[!cx]' 'abc'"
  ble/test "! strmatch -M 'ab[!cx]' 'abc'"
  ble/test "! strmatch -m 'ab[!cx]' 'abc'"

  # fixed-length pattern (?)
  ble/test "  strmatch    'a?c' 'abc'"
  ble/test "  strmatch -P 'a?c' 'abc'"
  ble/test "  strmatch -p 'a?c' 'abc'"
  ble/test "  strmatch -S 'a?c' 'abc'"
  ble/test "  strmatch -s 'a?c' 'abc'"
  ble/test "  strmatch -M 'a?c' 'abc'"
  ble/test "  strmatch -m 'a?c' 'abc'"

  ble/test "! strmatch    'a??c' 'abc'"
  ble/test "! strmatch -P 'a??c' 'abc'"
  ble/test "! strmatch -p 'a??c' 'abc'"
  ble/test "! strmatch -S 'a??c' 'abc'"
  ble/test "! strmatch -s 'a??c' 'abc'"
  ble/test "! strmatch -M 'a??c' 'abc'"
  ble/test "! strmatch -m 'a??c' 'abc'"

  ble/test "! strmatch    'abc?' 'abc'"
  ble/test "! strmatch -P 'abc?' 'abc'"
  ble/test "! strmatch -p 'abc?' 'abc'"
  ble/test "! strmatch -S 'abc?' 'abc'"
  ble/test "! strmatch -s 'abc?' 'abc'"
  ble/test "! strmatch -M 'abc?' 'abc'"
  ble/test "! strmatch -m 'abc?' 'abc'"

  ble/test "! strmatch    '?' 'abc'"
  ble/test "  strmatch -P '?' 'abc'"
  ble/test "  strmatch -p '?' 'abc'"
  ble/test "  strmatch -S '?' 'abc'"
  ble/test "  strmatch -s '?' 'abc'"
  ble/test "  strmatch -M '?' 'abc'"
  ble/test "  strmatch -m '?' 'abc'"

  ble/test "! strmatch    'a?' 'abc'"
  ble/test "  strmatch -P 'a?' 'abc'"
  ble/test "  strmatch -p 'a?' 'abc'"
  ble/test "! strmatch -S 'a?' 'abc'"
  ble/test "! strmatch -s 'a?' 'abc'"
  ble/test "  strmatch -M 'a?' 'abc'"
  ble/test "  strmatch -m 'a?' 'abc'"

  ble/test "! strmatch    '?[bc]' 'abc'"
  ble/test "  strmatch -P '?[bc]' 'abc'"
  ble/test "  strmatch -p '?[bc]' 'abc'"
  ble/test "  strmatch -S '?[bc]' 'abc'"
  ble/test "  strmatch -s '?[bc]' 'abc'"
  ble/test "  strmatch -M '?[bc]' 'abc'"
  ble/test "  strmatch -m '?[bc]' 'abc'"

  ble/test "  strmatch    'a?[!ab]' 'abc'"
  ble/test "  strmatch -P 'a?[!ab]' 'abc'"
  ble/test "  strmatch -p 'a?[!ab]' 'abc'"
  ble/test "  strmatch -S 'a?[!ab]' 'abc'"
  ble/test "  strmatch -s 'a?[!ab]' 'abc'"
  ble/test "  strmatch -M 'a?[!ab]' 'abc'"
  ble/test "  strmatch -m 'a?[!ab]' 'abc'"
)

ble/test/start-section 'strmatch (gmatch)' 183

(
  # single-star patterns
  ble/test "  strmatch    '*'     '0123456789'"
  ble/test "  strmatch    '0*'    '0123456789'"
  ble/test "  strmatch    '01*'   '0123456789'"
  ble/test "! strmatch    '02*'   '0123456789'"
  ble/test "  strmatch    '*9'    '0123456789'"
  ble/test "  strmatch    '*89'   '0123456789'"
  ble/test "! strmatch    '*79'   '0123456789'"
  ble/test "  strmatch    '0*9'   '0123456789'"
  ble/test "  strmatch    '01*9'  '0123456789'"
  ble/test "  strmatch    '01*89' '0123456789'"
  ble/test "! strmatch    '03*9'  '0123456789'"

  ble/test "  strmatch    '0123456789*' '0123456789'"
  ble/test "  strmatch    '*0123456789' '0123456789'"
  ble/test "  strmatch    '01234*56789' '0123456789'"

  ble/test "  strmatch -P '0*' '0123456789'"
  ble/test "  strmatch -p '0*' '0123456789'"
  ble/test "  strmatch -S '0*' '0123456789'"
  ble/test "  strmatch -s '0*' '0123456789'"
  ble/test "  strmatch -M '0*' '0123456789'"
  ble/test "  strmatch -m '0*' '0123456789'"

  ble/test "  strmatch -P '*9' '0123456789'"
  ble/test "  strmatch -p '*9' '0123456789'"
  ble/test "  strmatch -S '*9' '0123456789'"
  ble/test "  strmatch -s '*9' '0123456789'"
  ble/test "  strmatch -M '*9' '0123456789'"
  ble/test "  strmatch -m '*9' '0123456789'"

  ble/test "! strmatch -P '1*' '0123456789'"
  ble/test "! strmatch -p '1*' '0123456789'"
  ble/test "  strmatch -S '1*' '0123456789'"
  ble/test "  strmatch -s '1*' '0123456789'"
  ble/test "  strmatch -M '1*' '0123456789'"
  ble/test "  strmatch -m '1*' '0123456789'"

  ble/test "  strmatch -P '*8' '0123456789'"
  ble/test "  strmatch -p '*8' '0123456789'"
  ble/test "! strmatch -S '*8' '0123456789'"
  ble/test "! strmatch -s '*8' '0123456789'"
  ble/test "  strmatch -M '*8' '0123456789'"
  ble/test "  strmatch -m '*8' '0123456789'"

  ble/test "! strmatch -P '9*' '0123456789'"
  ble/test "! strmatch -p '9*' '0123456789'"
  ble/test "  strmatch -S '9*' '0123456789'"
  ble/test "  strmatch -s '9*' '0123456789'"
  ble/test "  strmatch -M '9*' '0123456789'"
  ble/test "  strmatch -m '9*' '0123456789'"

  ble/test "  strmatch -P '*0' '0123456789'"
  ble/test "  strmatch -p '*0' '0123456789'"
  ble/test "! strmatch -S '*0' '0123456789'"
  ble/test "! strmatch -s '*0' '0123456789'"
  ble/test "  strmatch -M '*0' '0123456789'"
  ble/test "  strmatch -m '*0' '0123456789'"

  # double-star patterns
  for mode in '' -{P,p,S,s,M,m}; do
    ble/test "  strmatch $mode '*0*'   '0123456789'"
    ble/test "  strmatch $mode '*9*'   '0123456789'"
    ble/test "  strmatch $mode '*5*'   '0123456789'"
    ble/test "  strmatch $mode '*34*'  '0123456789'"
    ble/test "  strmatch $mode '*345*' '0123456789'"
    ble/test "! strmatch $mode '*35*'  '0123456789'"
  done

  ble/test "  strmatch    '0*2*9' '0123456789'"
  ble/test "  strmatch -P '0*2*9' '0123456789'"
  ble/test "  strmatch -P '0*2*9' '0123456789'"
  ble/test "  strmatch -S '0*2*9' '0123456789'"
  ble/test "  strmatch -s '0*2*9' '0123456789'"
  ble/test "  strmatch -M '0*2*9' '0123456789'"
  ble/test "  strmatch -m '0*2*9' '0123456789'"

  ble/test "! strmatch    '1*2*9' '0123456789'"
  ble/test "! strmatch -P '1*2*9' '0123456789'"
  ble/test "! strmatch -P '1*2*9' '0123456789'"
  ble/test "  strmatch -S '1*2*9' '0123456789'"
  ble/test "  strmatch -s '1*2*9' '0123456789'"
  ble/test "  strmatch -M '1*2*9' '0123456789'"
  ble/test "  strmatch -m '1*2*9' '0123456789'"

  ble/test "! strmatch    '1*2*8' '0123456789'"
  ble/test "! strmatch -P '1*2*8' '0123456789'"
  ble/test "! strmatch -P '1*2*8' '0123456789'"
  ble/test "! strmatch -S '1*2*8' '0123456789'"
  ble/test "! strmatch -s '1*2*8' '0123456789'"
  ble/test "  strmatch -M '1*2*8' '0123456789'"
  ble/test "  strmatch -m '1*2*8' '0123456789'"

  ble/test "! strmatch    '0*2*8' '0123456789'"
  ble/test "  strmatch -P '0*2*8' '0123456789'"
  ble/test "  strmatch -P '0*2*8' '0123456789'"
  ble/test "! strmatch -S '0*2*8' '0123456789'"
  ble/test "! strmatch -s '0*2*8' '0123456789'"
  ble/test "  strmatch -M '0*2*8' '0123456789'"
  ble/test "  strmatch -m '0*2*8' '0123456789'"

  ble/test "  strmatch    '0*2*' '0123456789'"
  ble/test "  strmatch -P '0*2*' '0123456789'"
  ble/test "  strmatch -P '0*2*' '0123456789'"
  ble/test "  strmatch -S '0*2*' '0123456789'"
  ble/test "  strmatch -s '0*2*' '0123456789'"
  ble/test "  strmatch -M '0*2*' '0123456789'"
  ble/test "  strmatch -m '0*2*' '0123456789'"

  ble/test "! strmatch    '1*2*' '0123456789'"
  ble/test "! strmatch -P '1*2*' '0123456789'"
  ble/test "! strmatch -P '1*2*' '0123456789'"
  ble/test "  strmatch -S '1*2*' '0123456789'"
  ble/test "  strmatch -s '1*2*' '0123456789'"
  ble/test "  strmatch -M '1*2*' '0123456789'"
  ble/test "  strmatch -m '1*2*' '0123456789'"

  ble/test "  strmatch    '*2*9' '0123456789'"
  ble/test "  strmatch -P '*2*9' '0123456789'"
  ble/test "  strmatch -P '*2*9' '0123456789'"
  ble/test "  strmatch -S '*2*9' '0123456789'"
  ble/test "  strmatch -s '*2*9' '0123456789'"
  ble/test "  strmatch -M '*2*9' '0123456789'"
  ble/test "  strmatch -m '*2*9' '0123456789'"

  ble/test "! strmatch    '*2*8' '0123456789'"
  ble/test "  strmatch -P '*2*8' '0123456789'"
  ble/test "  strmatch -P '*2*8' '0123456789'"
  ble/test "! strmatch -S '*2*8' '0123456789'"
  ble/test "! strmatch -s '*2*8' '0123456789'"
  ble/test "  strmatch -M '*2*8' '0123456789'"
  ble/test "  strmatch -m '*2*8' '0123456789'"

  ble/test "! strmatch    '*[!0-9]*' '0123456789'"
  ble/test "! strmatch -P '*[!0-9]*' '0123456789'"
  ble/test "! strmatch -P '*[!0-9]*' '0123456789'"
  ble/test "! strmatch -S '*[!0-9]*' '0123456789'"
  ble/test "! strmatch -s '*[!0-9]*' '0123456789'"
  ble/test "! strmatch -M '*[!0-9]*' '0123456789'"
  ble/test "! strmatch -m '*[!0-9]*' '0123456789'"

  ble/test "  strmatch    '*[0-9]*' '0123456789'"
  ble/test "  strmatch -P '*[0-9]*' '0123456789'"
  ble/test "  strmatch -P '*[0-9]*' '0123456789'"
  ble/test "  strmatch -S '*[0-9]*' '0123456789'"
  ble/test "  strmatch -s '*[0-9]*' '0123456789'"
  ble/test "  strmatch -M '*[0-9]*' '0123456789'"
  ble/test "  strmatch -m '*[0-9]*' '0123456789'"

  ble/test "  strmatch    '[0-9]*[0-9]*[0-9]' '0123456789'"
  ble/test "  strmatch -P '[0-9]*[0-9]*[0-9]' '0123456789'"
  ble/test "  strmatch -P '[0-9]*[0-9]*[0-9]' '0123456789'"
  ble/test "  strmatch -S '[0-9]*[0-9]*[0-9]' '0123456789'"
  ble/test "  strmatch -s '[0-9]*[0-9]*[0-9]' '0123456789'"
  ble/test "  strmatch -M '[0-9]*[0-9]*[0-9]' '0123456789'"
  ble/test "  strmatch -m '[0-9]*[0-9]*[0-9]' '0123456789'"

  # does not match the same character twice
  ble/test "! strmatch    '*2*2*' '0123456789'"
  ble/test "! strmatch -P '*2*2*' '0123456789'"
  ble/test "! strmatch -P '*2*2*' '0123456789'"
  ble/test "! strmatch -S '*2*2*' '0123456789'"
  ble/test "! strmatch -s '*2*2*' '0123456789'"
  ble/test "! strmatch -M '*2*2*' '0123456789'"
  ble/test "! strmatch -m '*2*2*' '0123456789'"

  ble/test "! strmatch    '*2*[0-2]*' '0123456789'"
  ble/test "! strmatch -P '*2*[0-2]*' '0123456789'"
  ble/test "! strmatch -P '*2*[0-2]*' '0123456789'"
  ble/test "! strmatch -S '*2*[0-2]*' '0123456789'"
  ble/test "! strmatch -s '*2*[0-2]*' '0123456789'"
  ble/test "! strmatch -M '*2*[0-2]*' '0123456789'"
  ble/test "! strmatch -m '*2*[0-2]*' '0123456789'"
)

ble/test/start-section 'negation' 8

(
  ble/test "  strmatch    '!(*.ext)' 'a.txt'"
  ble/test "! strmatch    '!(*.ext)' 'a.ext'"
  ble/test "  strmatch -P '!(*.ext)' 'a.txt'"
  ble/test "  strmatch -P '!(*.ext)' 'a.ext'"
  ble/test "  strmatch -S '!(*.ext)' 'a.txt'"
  ble/test "  strmatch -S '!(*.ext)' 'a.ext'"
  ble/test "  strmatch -m '!(*.ext)' 'a.txt'"
  ble/test "  strmatch -m '!(*.ext)' 'a.ext'"
)

ble/test/end-section
