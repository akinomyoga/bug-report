#!/usr/bin/env bash

LC_COLLATE=C

#------------------------------------------------------------------------------
# loadable builtins

# [[ ./fnmatch -nt fnmatch.c ]] ||
#   gcc -O2 -o ./fnmatch fnmatch.c

[[ ./strmatch.so -nt strmatch_builtin.c ]] ||
  gcc -O2 -shared -fPIC -o ./strmatch.so strmatch_builtin.c
[[ ./strmatch_ex.so -nt strmatch_builtin.c ]] ||
  gcc -O2 -shared -fPIC -DASSIGN_BASH_STRMATCH -o ./strmatch_ex.so strmatch_builtin.c

if (enable -f ./strmatch_ex.so strmatch && strmatch -P x xyz) 2>/dev/null; then
  enable -f ./strmatch_ex.so strmatch
  _glob_engine=new
else
  enable -f ./strmatch.so strmatch
  _glob_engine=old
fi

#------------------------------------------------------------------------------
# test framework

if [[ -r ~/.mwg/src/ble.sh/out/ble.sh ]]; then
  source ~/.mwg/src/ble.sh/out/ble.sh --lib
  ble-import lib/core-test
else
  function ble/test/start-section {
    printf '%s\n' "===== $1 =====" >&2
  }
  function ble/test/end-section {
    : do nothing
  }
  function ble/test {
    while [[ $1 == --depth=* || $1 == --display-code=* ]]; do shift; done

    local code=${1#code[:=]}
    shift

    local exit_expect=0 ret_expect=__unspecified__
    local -a conditions
    local cond
    for cond; do
      case $cond in
      (ret[:=]*)
        ret_expect=${cond#*[:=]} ;;
      (exit[:=]*)
        exit_expect=${cond#*[:=]} ;;
      esac
    done

    builtin eval -- "$code"
    local exit=$?

    local msg=
    [[ $exit == "$exit_expect" ]] ||
      msg+="  exit-status is $exit (expect: $exit_expect)"$'\n'
    [[ $ret_expect == __unspecified__ || $ret == "$ret_expect" ]] ||
      msg+="  result is '$ret' (expect: '$ret_expect')"$'\n'
    if [[ $msg ]]; then
      printf '%s\n' "TEST ${_test_title:-$code}"
      printf '%s' "$msg"
      return 1
    fi

    return 0
  }
fi

#------------------------------------------------------------------------------
# test helpers

function ble/test:strmatch.1 {
  strmatch $option "$pat" "$str"
  local stat=$?

  if [[ $_glob_engine == new ]]; then
    # summarize BASH_STRMATCH & BASH_STRSTART
    local index arr
    for index in "${!BASH_STRMATCH[@]}"; do
      arr+=("${BASH_STRSTART[index]}:${BASH_STRMATCH[index]}")
    done
    ret="(${arr[*]})"
  fi

  return "$stat"
}

function ble/test:strmatch {
  local option=
  if [[ $1 == -? ]]; then
    option=$1
    shift
  fi
  if [[ $option == -*[PpSsMm]* && $_glob_engine == old ]]; then
    # Function `strmatch` by the old engine does not support -[PpSsMm]
    # flags, so we skip the test.
    return 0
  fi

  local pat=$1 str=$2
  shift 2

  local _test_title="strmatch${option:+ $option} '${pat//$q/$Q}' '${str//$q/$Q}'"

  local -a conditions
  local cond
  for cond; do
    [[ $cond == ret[:=]* && $_glob_engine == old ]] && continue
    conditions+=("$cond")
  done

  local q=\' Q="'\''"
  ble/test --depth=1 --display-code="$_test_title" \
           code:"ble/test:strmatch.1" "${conditions[@]}"
}

#------------------------------------------------------------------------------
# tests

ble/test/start-section 'strmatch (fmatch)' 170

(
  # fixed strings
  ble/test:strmatch hello hello ret='(0:hello)'
  ble/test:strmatch hello world exit=1 ret='()'

  ble/test:strmatch    abc abc ret='(0:abc)'
  ble/test:strmatch -P abc abc ret='(0:abc)'
  ble/test:strmatch -p abc abc ret='(0:abc)'
  ble/test:strmatch -S abc abc ret='(0:abc)'
  ble/test:strmatch -s abc abc ret='(0:abc)'
  ble/test:strmatch -M abc abc ret='(0:abc)'
  ble/test:strmatch -m abc abc ret='(0:abc)'

  ble/test:strmatch    ab abc exit=1 ret='()'
  ble/test:strmatch -P ab abc ret='(0:ab)'
  ble/test:strmatch -p ab abc ret='(0:ab)'
  ble/test:strmatch -S ab abc exit=1 ret='()'
  ble/test:strmatch -s ab abc exit=1 ret='()'
  ble/test:strmatch -M ab abc ret='(0:ab)'
  ble/test:strmatch -m ab abc ret='(0:ab)'

  ble/test:strmatch    bc abc exit=1 ret='()'
  ble/test:strmatch -P bc abc exit=1 ret='()'
  ble/test:strmatch -p bc abc exit=1 ret='()'
  ble/test:strmatch -S bc abc ret='(1:bc)'
  ble/test:strmatch -s bc abc ret='(1:bc)'
  ble/test:strmatch -M bc abc ret='(1:bc)'
  ble/test:strmatch -m bc abc ret='(1:bc)'

  ble/test:strmatch    '' abc exit=1 ret='()'
  ble/test:strmatch -P '' abc ret='(0:)'
  ble/test:strmatch -p '' abc ret='(0:)'
  ble/test:strmatch -S '' abc ret='(3:)'
  ble/test:strmatch -s '' abc ret='(3:)'
  ble/test:strmatch -M '' abc ret='(0: 1: 2: 3:)'
  ble/test:strmatch -m '' abc ret='(0:)'

  ble/test:strmatch    b abc exit=1 ret='()'
  ble/test:strmatch -P b abc exit=1 ret='()'
  ble/test:strmatch -p b abc exit=1 ret='()'
  ble/test:strmatch -S b abc exit=1 ret='()'
  ble/test:strmatch -s b abc exit=1 ret='()'
  ble/test:strmatch -M b abc ret='(1:b)'
  ble/test:strmatch -m b abc ret='(1:b)'

  ble/test:strmatch    ac abc exit=1 ret='()'
  ble/test:strmatch -P ac abc exit=1 ret='()'
  ble/test:strmatch -p ac abc exit=1 ret='()'
  ble/test:strmatch -S ac abc exit=1 ret='()'
  ble/test:strmatch -s ac abc exit=1 ret='()'
  ble/test:strmatch -M ac abc exit=1 ret='()'
  ble/test:strmatch -m ac abc exit=1 ret='()'

  # fixed-length pattern (bracket expression)
  ble/test:strmatch    'a[abc]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a[abc]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a[abc]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a[abc]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a[abc]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a[abc]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a[abc]c' 'abc' ret='(0:abc)'

  ble/test:strmatch    'a[a-c]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a[a-c]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a[a-c]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a[a-c]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a[a-c]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a[a-c]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a[a-c]c' 'abc' ret='(0:abc)'

  ble/test:strmatch    'a[!ac]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a[!ac]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a[!ac]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a[!ac]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a[!ac]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a[!ac]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a[!ac]c' 'abc' ret='(0:abc)'

  ble/test:strmatch    'a[[=b=]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a[[=b=]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a[[=b=]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a[[=b=]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a[[=b=]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a[[=b=]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a[[=b=]]c' 'abc' ret='(0:abc)'

  ble/test:strmatch    'a[![=b=]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -P 'a[![=b=]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -p 'a[![=b=]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -S 'a[![=b=]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -s 'a[![=b=]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -M 'a[![=b=]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -m 'a[![=b=]]c' 'abc' exit=1 ret='()'

  ble/test:strmatch    'a[[:alpha:]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a[[:alpha:]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a[[:alpha:]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a[[:alpha:]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a[[:alpha:]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a[[:alpha:]]c' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a[[:alpha:]]c' 'abc' ret='(0:abc)'

  ble/test:strmatch    'a[![:alpha:]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -P 'a[![:alpha:]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -p 'a[![:alpha:]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -S 'a[![:alpha:]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -s 'a[![:alpha:]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -M 'a[![:alpha:]]c' 'abc' exit=1 ret='()'
  ble/test:strmatch -m 'a[![:alpha:]]c' 'abc' exit=1 ret='()'

  ble/test:strmatch    '[ax]bc' 'abc' ret='(0:abc)'
  ble/test:strmatch -P '[ax]bc' 'abc' ret='(0:abc)'
  ble/test:strmatch -p '[ax]bc' 'abc' ret='(0:abc)'
  ble/test:strmatch -S '[ax]bc' 'abc' ret='(0:abc)'
  ble/test:strmatch -s '[ax]bc' 'abc' ret='(0:abc)'
  ble/test:strmatch -M '[ax]bc' 'abc' ret='(0:abc)'
  ble/test:strmatch -m '[ax]bc' 'abc' ret='(0:abc)'

  ble/test:strmatch    'ab[cx]' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'ab[cx]' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'ab[cx]' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'ab[cx]' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'ab[cx]' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'ab[cx]' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'ab[cx]' 'abc' ret='(0:abc)'

  ble/test:strmatch    '[!ax]bc' 'abc' exit=1 ret='()'
  ble/test:strmatch -P '[!ax]bc' 'abc' exit=1 ret='()'
  ble/test:strmatch -p '[!ax]bc' 'abc' exit=1 ret='()'
  ble/test:strmatch -S '[!ax]bc' 'abc' exit=1 ret='()'
  ble/test:strmatch -s '[!ax]bc' 'abc' exit=1 ret='()'
  ble/test:strmatch -M '[!ax]bc' 'abc' exit=1 ret='()'
  ble/test:strmatch -m '[!ax]bc' 'abc' exit=1 ret='()'

  ble/test:strmatch    'ab[!cx]' 'abc' exit=1 ret='()'
  ble/test:strmatch -P 'ab[!cx]' 'abc' exit=1 ret='()'
  ble/test:strmatch -p 'ab[!cx]' 'abc' exit=1 ret='()'
  ble/test:strmatch -S 'ab[!cx]' 'abc' exit=1 ret='()'
  ble/test:strmatch -s 'ab[!cx]' 'abc' exit=1 ret='()'
  ble/test:strmatch -M 'ab[!cx]' 'abc' exit=1 ret='()'
  ble/test:strmatch -m 'ab[!cx]' 'abc' exit=1 ret='()'

  # fixed-length pattern (?)
  ble/test:strmatch    'a?c' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a?c' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a?c' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a?c' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a?c' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a?c' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a?c' 'abc' ret='(0:abc)'

  ble/test:strmatch    'a??c' 'abc' exit=1 ret='()'
  ble/test:strmatch -P 'a??c' 'abc' exit=1 ret='()'
  ble/test:strmatch -p 'a??c' 'abc' exit=1 ret='()'
  ble/test:strmatch -S 'a??c' 'abc' exit=1 ret='()'
  ble/test:strmatch -s 'a??c' 'abc' exit=1 ret='()'
  ble/test:strmatch -M 'a??c' 'abc' exit=1 ret='()'
  ble/test:strmatch -m 'a??c' 'abc' exit=1 ret='()'

  ble/test:strmatch    'abc?' 'abc' exit=1 ret='()'
  ble/test:strmatch -P 'abc?' 'abc' exit=1 ret='()'
  ble/test:strmatch -p 'abc?' 'abc' exit=1 ret='()'
  ble/test:strmatch -S 'abc?' 'abc' exit=1 ret='()'
  ble/test:strmatch -s 'abc?' 'abc' exit=1 ret='()'
  ble/test:strmatch -M 'abc?' 'abc' exit=1 ret='()'
  ble/test:strmatch -m 'abc?' 'abc' exit=1 ret='()'

  ble/test:strmatch    '?' 'abc' exit=1 ret='()'
  ble/test:strmatch -P '?' 'abc' ret='(0:a)'
  ble/test:strmatch -p '?' 'abc' ret='(0:a)'
  ble/test:strmatch -S '?' 'abc' ret='(2:c)'
  ble/test:strmatch -s '?' 'abc' ret='(2:c)'
  ble/test:strmatch -M '?' 'abc' ret='(0:a 1:b 2:c)'
  ble/test:strmatch -m '?' 'abc' ret='(0:a)'

  ble/test:strmatch    'a?' 'abc' exit=1 ret='()'
  ble/test:strmatch -P 'a?' 'abc' ret='(0:ab)'
  ble/test:strmatch -p 'a?' 'abc' ret='(0:ab)'
  ble/test:strmatch -S 'a?' 'abc' exit=1 ret='()'
  ble/test:strmatch -s 'a?' 'abc' exit=1 ret='()'
  ble/test:strmatch -M 'a?' 'abc' ret='(0:ab)'
  ble/test:strmatch -m 'a?' 'abc' ret='(0:ab)'

  ble/test:strmatch    '?[bc]' 'abc' exit=1 ret='()'
  ble/test:strmatch -P '?[bc]' 'abc' ret='(0:ab)'
  ble/test:strmatch -p '?[bc]' 'abc' ret='(0:ab)'
  ble/test:strmatch -S '?[bc]' 'abc' ret='(1:bc)'
  ble/test:strmatch -s '?[bc]' 'abc' ret='(1:bc)'
  ble/test:strmatch -M '?[bc]' 'abc' ret='(0:ab)'
  ble/test:strmatch -m '?[bc]' 'abc' ret='(0:ab)'

  ble/test:strmatch    'a?[!ab]' 'abc' ret='(0:abc)'
  ble/test:strmatch -P 'a?[!ab]' 'abc' ret='(0:abc)'
  ble/test:strmatch -p 'a?[!ab]' 'abc' ret='(0:abc)'
  ble/test:strmatch -S 'a?[!ab]' 'abc' ret='(0:abc)'
  ble/test:strmatch -s 'a?[!ab]' 'abc' ret='(0:abc)'
  ble/test:strmatch -M 'a?[!ab]' 'abc' ret='(0:abc)'
  ble/test:strmatch -m 'a?[!ab]' 'abc' ret='(0:abc)'
)

ble/test/start-section 'strmatch (gmatch)' 183

(
  # single-star patterns
  ble/test:strmatch    '*'     '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '0*'    '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '01*'   '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '02*'   '0123456789' exit=1 ret='()'
  ble/test:strmatch    '*9'    '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '*89'   '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '*79'   '0123456789' exit=1 ret='()'
  ble/test:strmatch    '0*9'   '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '01*9'  '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '01*89' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '03*9'  '0123456789' exit=1 ret='()'

  ble/test:strmatch    '0123456789*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '*0123456789' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch    '01234*56789' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch -P '0*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '0*' '0123456789' ret='(0:0)'
  ble/test:strmatch -S '0*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '0*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -M '0*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '0*' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch -P '*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -S '*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '*9' '0123456789' ret='(9:9)'
  ble/test:strmatch -M '*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '*9' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch -P '1*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '1*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '1*' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -s '1*' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -M '1*' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -m '1*' '0123456789' ret='(1:123456789)'

  ble/test:strmatch -P '*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -p '*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -S '*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -m '*8' '0123456789' ret='(0:012345678)'

  ble/test:strmatch -P '9*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '9*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '9*' '0123456789' ret='(9:9)'
  ble/test:strmatch -s '9*' '0123456789' ret='(9:9)'
  ble/test:strmatch -M '9*' '0123456789' ret='(9:9)'
  ble/test:strmatch -m '9*' '0123456789' ret='(9:9)'

  ble/test:strmatch -P '*0' '0123456789' ret='(0:0)'
  ble/test:strmatch -p '*0' '0123456789' ret='(0:0)'
  ble/test:strmatch -S '*0' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*0' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '*0' '0123456789' ret='(0:0)'
  ble/test:strmatch -m '*0' '0123456789' ret='(0:0)'

  # double-star patterns
  for mode in '' -{P,S,M,m}; do
    ble/test:strmatch $mode '*0*'   '0123456789' ret='(0:0123456789)'
    ble/test:strmatch $mode '*9*'   '0123456789' ret='(0:0123456789)'
    ble/test:strmatch $mode '*5*'   '0123456789' ret='(0:0123456789)'
    ble/test:strmatch $mode '*34*'  '0123456789' ret='(0:0123456789)'
    ble/test:strmatch $mode '*345*' '0123456789' ret='(0:0123456789)'
    ble/test:strmatch $mode '*35*'  '0123456789' exit=1 ret='()'
  done
  ble/test:strmatch -p '*0*'   '0123456789' ret='(0:0)'
  ble/test:strmatch -p '*9*'   '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '*5*'   '0123456789' ret='(0:012345)'
  ble/test:strmatch -p '*34*'  '0123456789' ret='(0:01234)'
  ble/test:strmatch -p '*345*' '0123456789' ret='(0:012345)'
  ble/test:strmatch -p '*35*'  '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*0*'   '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '*9*'   '0123456789' ret='(9:9)'
  ble/test:strmatch -s '*5*'   '0123456789' ret='(5:56789)'
  ble/test:strmatch -s '*34*'  '0123456789' ret='(3:3456789)'
  ble/test:strmatch -s '*345*' '0123456789' ret='(3:3456789)'
  ble/test:strmatch -s '*35*'  '0123456789' exit=1 ret='()'

  ble/test:strmatch    '0*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -P '0*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '0*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -S '0*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '0*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -M '0*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '0*2*9' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch    '1*2*9' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '1*2*9' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '1*2*9' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '1*2*9' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -s '1*2*9' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -M '1*2*9' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -m '1*2*9' '0123456789' ret='(1:123456789)'

  ble/test:strmatch    '1*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '1*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '1*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '1*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '1*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '1*2*8' '0123456789' ret='(1:12345678)'
  ble/test:strmatch -m '1*2*8' '0123456789' ret='(1:12345678)'

  ble/test:strmatch    '0*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '0*2*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -p '0*2*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -S '0*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '0*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '0*2*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -m '0*2*8' '0123456789' ret='(0:012345678)'

  ble/test:strmatch    '0*2*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -P '0*2*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '0*2*' '0123456789' ret='(0:012)'
  ble/test:strmatch -S '0*2*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '0*2*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -M '0*2*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '0*2*' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch    '1*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '1*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '1*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '1*2*' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -s '1*2*' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -M '1*2*' '0123456789' ret='(1:123456789)'
  ble/test:strmatch -m '1*2*' '0123456789' ret='(1:123456789)'

  ble/test:strmatch    '*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -P '*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -S '*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '*2*9' '0123456789' ret='(2:23456789)'
  ble/test:strmatch -M '*2*9' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '*2*9' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch    '*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '*2*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -p '*2*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -S '*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*2*8' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '*2*8' '0123456789' ret='(0:012345678)'
  ble/test:strmatch -m '*2*8' '0123456789' ret='(0:012345678)'

  ble/test:strmatch    '*[!0-9]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '*[!0-9]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '*[!0-9]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '*[!0-9]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*[!0-9]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '*[!0-9]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -m '*[!0-9]*' '0123456789' exit=1 ret='()'

  ble/test:strmatch    '*[0-9]*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -P '*[0-9]*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '*[0-9]*' '0123456789' ret='(0:0)'
  ble/test:strmatch -S '*[0-9]*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '*[0-9]*' '0123456789' ret='(9:9)'
  ble/test:strmatch -M '*[0-9]*' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '*[0-9]*' '0123456789' ret='(0:0123456789)'

  ble/test:strmatch    '[0-9]*[0-9]*[0-9]' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -P '[0-9]*[0-9]*[0-9]' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -p '[0-9]*[0-9]*[0-9]' '0123456789' ret='(0:012)'
  ble/test:strmatch -S '[0-9]*[0-9]*[0-9]' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -s '[0-9]*[0-9]*[0-9]' '0123456789' ret='(7:789)'
  ble/test:strmatch -M '[0-9]*[0-9]*[0-9]' '0123456789' ret='(0:0123456789)'
  ble/test:strmatch -m '[0-9]*[0-9]*[0-9]' '0123456789' ret='(0:0123456789)'

  # does not match the same character twice
  ble/test:strmatch    '*2*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '*2*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '*2*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '*2*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*2*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '*2*2*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -m '*2*2*' '0123456789' exit=1 ret='()'

  ble/test:strmatch    '*2*[0-2]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -P '*2*[0-2]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -p '*2*[0-2]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -S '*2*[0-2]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -s '*2*[0-2]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -M '*2*[0-2]*' '0123456789' exit=1 ret='()'
  ble/test:strmatch -m '*2*[0-2]*' '0123456789' exit=1 ret='()'
)

ble/test/start-section 'negation' 12

(
  ble/test:strmatch    '!(*.ext)' 'a.txt' ret='(0:a.txt)'
  ble/test:strmatch    '!(*.ext)' 'a.ext' exit=1 ret='()'
  ble/test:strmatch -P '!(*.ext)' 'a.txt' ret='(0:a.txt)'
  ble/test:strmatch -P '!(*.ext)' 'a.ext' ret='(0:a.ex)'
  ble/test:strmatch -S '!(*.ext)' 'a.txt' ret='(0:a.txt)'
  ble/test:strmatch -S '!(*.ext)' 'a.ext' ret='(2:ext)'
  ble/test:strmatch -m '!(*.ext)' 'a.txt' ret='(0:a.txt)'
  ble/test:strmatch -m '!(*.ext)' 'a.ext' ret='(0:a.ex)'

  # nested negation
  ble/test:strmatch '!(!(*.?x?)|!(*.e?t))' 'a.zip' exit=1 ret='()'
  ble/test:strmatch '!(!(*.?x?)|!(*.e?t))' 'a.eat' exit=1 ret='()'
  ble/test:strmatch '!(!(*.?x?)|!(*.e?t))' 'a.txt' exit=1 ret='()'
  ble/test:strmatch '!(!(*.?x?)|!(*.e?t))' 'a.ext' ret='(0:a.ext)'
)

ble/test/start-section 'pat_subst with nocasematch' 6

(
  v=alpha
  ble/test code:"ret=${v/a/x}" ret=xlpha
  ble/test code:"ret=${v//a/x}" ret=xlphx
  shopt -u nocasematch
  ble/test code:"ret=${v/A/x}" ret=alpha
  ble/test code:"ret=${v//A/x}" ret=alpha
  shopt -s nocasematch
  ble/test code:"ret=${v/A/x}" ret=xlpha
  ble/test code:"ret=${v//A/x}" ret=xlphx
)

ble/test/start-section 'incomplete extglob' 9

(
  # incomplete glob @(
  if [[ $_glob_engine == old ]]; then
    # In the old implementation, the pattern before the introducer of an
    # incomplete extglob is treated as a glob pattern, and the pattern after
    # the introducer is treated as a literally matching string.
    ble/test:strmatch    'a*b@('           'aZZZZZb@('
    ble/test:strmatch    '@(@(xyz)'        '@(@(xyz)'
    ble/test:strmatch    'foo*(bar*@(baz)' 'foo*(bar*@(baz)'
  else
    # In the new implementation, the introducer is interpreted without extglob,
    # and the rest pattern is interpreted with extglob enabled.
    ble/test:strmatch    'a*b@('           'aZZZZZb@('
    ble/test:strmatch    '@(@(xyz)'        '@(xyz'
    ble/test:strmatch    'foo*(bar*@(baz)' 'fooXXXX(barYYYYbaz'
  fi

  # incomplete glob *(
  ble/test:strmatch    'foo**(bar)'      'fooXXX'
  ble/test:strmatch    'foo**(bar)'      'fooXXXbarbarbar'
  if [[ $_glob_engine == old ]]; then
    # In the old implementation, only for the case **(bar, incompelte extglob
    # constructs makes the pattern match any strings.  This behavior is
    # inconsistent with the cases of other incomplete extglob constructs.
    ble/test:strmatch    'foo**(bar'       'fooXXX*(bar'
    ble/test:strmatch    'foo**(bar'       'fooXXXYYY(bar'
    ble/test:strmatch    'foo**(bar'       'foo'
    ble/test:strmatch    'foo**(bar'       'fooXYZ'
  else
    # In the new implementation, `(` of incomplete `**(` is treated as a
    # literally matching character, and the other `*`s are treated as normal
    # wildcards.
    ble/test:strmatch    'foo**(bar'       'fooXXX*(bar'
    ble/test:strmatch    'foo**(bar'       'fooXXXYYY(bar'
    ble/test:strmatch    'foo**(bar'       'foo'           exit=1 ret='()'
    ble/test:strmatch    'foo**(bar'       'fooXYZ'        exit=1 ret='()'
  fi
)

ble/test/end-section
