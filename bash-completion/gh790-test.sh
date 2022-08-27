# -*- mode: sh; mode: sh-bash -*-

#source bash-completion/bash_completion

outfile_python_tests=gh790-test.generated.py

#------------------------------------------------------------------------------
# implementation in PR #791

_comp_command_offset__initialize_regex()
{
    [[ -v _comp_command_offset__mut_initialized && $COMP_WORDBREAKS == "$_comp_command_offset__mut_initialized" ]] && return
    _comp_command_offset__mut_initialized=$COMP_WORDBREAKS
    _comp_command_offset__mut_regex_closed_prefix='^([^\"'\'']|\\.|"([^\"]|\\.)*"|'\''[^'\'']*'\'')*'
    local chars=${COMP_WORDBREAKS//[\'\"]/} regex_break=
    [[ $chars == *\\* ]] && chars=${chars//\\/} regex_break='\\(.|$)'
    [[ $chars == *\$* ]] && chars=${chars//\$/} regex_break+=${regex_break:+'|'}'\$([^$'\'${regex_break:+\\}']|$)'
    if [[ $chars == '^' ]]; then
        regex_break+=${regex_break:+'|'}'\^'
    elif [[ $chars ]]; then
        [[ $chars == ?*']'* ]] && chars=']'${chars//']'/}
        [[ $chars == '^'* ]] && chars=${chars:1}${chars::1}
        [[ $chars == *'-'*? ]] && chars=${chars//'-'/}'-'
        regex_break+=${regex_break:+'|'}[$chars]
    fi
    _comp_command_offset__mut_regex_break='^([^\"'\''$]|\$*\\.|\$*"([^\"]|\\.)*"|'\''[^'\'']*'\''|\$+'\''([^'\''\]|\\.)*'\''|\$+([^'\'']|$))*\$*('${regex_break:-'^$'}')'
}

_comp_command_offset__reduce_cur()
{
    _comp_command_offset__initialize_regex
    ret=$1
    if [[ $ret =~ $_comp_command_offset__mut_regex_closed_prefix && ${ret:${#BASH_REMATCH}} == [\'\"]* ]]; then
        ret=${ret:${#BASH_REMATCH}+1}
    elif [[ $ret =~ $_comp_command_offset__mut_regex_break ]]; then
        ret=${ret:${#BASH_REMATCH}}
        [[ ${BASH_REMATCH[5]} == @(\$*|@|\\?) ]] && ret=${BASH_REMATCH[5]#\\}$ret
    fi
}

#------------------------------------------------------------------------------
# implementation by mug896

shopt -s extglob

_mug896_impl()
{
  # fake compvars
  local COMP_LINE="test1 $1"
  local COMP_POINT=${#COMP_LINE}
  local -a COMP_WORDS=(test1 "$1")
  local COMP_CWORD=1
  _parse_print() { ret=$2; }
  _parse
}
_parse()
{
  local comp=${COMP_WORDS[COMP_CWORD]}
  local match=0 two i

  if [[ ${comp:0:1} != @(\"|\') && $COMP_WORDBREAKS == *"${comp:0:1}"* ]]; then
    _parse_print "$1" "" "${COMP_WORDS[COMP_CWORD-1]}"
    return
  fi

  for (( i = 0; i < ${#comp}; i++ )); do
    [[ ${COMP_LINE:0:COMP_POINT} == *"${comp:0:i+1}" ]] && let match=i+1
  done

  local str=${comp:0:match}
  local open=-1 curq=""

  for ((i = 0; i < ${#str}; i++)); do
    case ${str:i:1} in
    \") 
      [[ $curq == single ]] && continue
      (( open == -1 )) && { open=$i; curq="double" ;} || { open=-1; curq="" ;}
      ;;
    \') 
      [[ $curq == double ]] && continue
      (( open == -1 )) && { open=$i; curq="single" ;} || { open=-1; curq="" ;}
      ;;
    \\) 
      [[ ${str:i+1:1} == @(\"|\'|\\) && $curq != single ]] && let i++
      ;;
    esac
  done
  if (( open == -1 )); then
    two=$str
  else
    str=${str:open} 
    two=${str#@(\"|\')}
  fi
  _parse_print "$1" "$two" "${COMP_WORDS[COMP_CWORD-1]}"
}

#------------------------------------------------------------------------------

case $1 in
(mug896)
  impl=_mug896_impl ;;
(*)
  impl=_comp_command_offset__reduce_cur ;;
esac

test_count=0
pass_count=0
function test1 {
  local input=$1 expect=$2 ret=__undefined__
  "$impl" "$input"
  ((test_count++))
  if [[ $ret == "$expect" ]]; then
    ((pass_count++))
  else
    echo "line $BASH_LINENO: failed: input=<$input> output=<$ret> expect=<$expect>" >&2
  fi

  local q_input=${input//\\/\\\\}; q_input=\"${q_input//\"/\\\"}\"
  local q_expect=${expect//\\/\\\\}; q_expect=\"${q_expect//\"/\\\"}\"
  echo "  ($q_input, $q_expect)," >> "$outfile_python_tests"
}

function gen_wordbreaks {
  local q_break=${COMP_WORDBREAKS//\\/\\\\}
  q_break=${q_break//$'\t'/\\\t}
  q_break=${q_break//$'\n'/\\\n}
  q_break=\"${q_break//\"/\\\"}\"
  echo "bash_env.write_variable(\"COMP_WORDBREAKS\", $q_break)" >> "$outfile_python_tests"
}


: > "$outfile_python_tests"

test1 '=='                                    ''
test1 '=:'                                    ''
test1 '--foo'\''='                            '='
test1 '='                                     ''
test1 ''\''='                                 '='
test1 ''\''='\'''                             ''\''='\'''
test1 'a"b'                                   'b'
test1 'a"b"'                                  'a"b"'
test1 'a"b"c'                                 'a"b"c'
test1 'a"b"c"'                                ''
test1 'a'                                     'a'
test1 'ab'                                    'ab'
test1 'abc'                                   'abc'
test1 'abcd'                                  'abcd'

test1 'a"a$(echo'                             'a$(echo'
test1 'a"a$(echo "'                           'a"a$(echo "'
test1 'a"a$(echo "world"x'                    'x'
test1 'a"a$(echo "world"x)'                   'x)'
test1 'a${va'                                 'a${va'
test1 '$'\''a'                                'a'
test1 '$'\''a\n'                              'a\n'
test1 '$'\''a\n\'\'''                         '$'\''a\n\'\'''
test1 '$'\''a\n\'\'' '\'''                    ''
test1 '$'\''a\n\'\'' \'\''x'                  '$'\''a\n\'\'' \'\''x'
test1 '$'\''a\n\'\'' \'\''xyz'\''x'           'x'
test1 'a'\''bb\'\''aaa'                       'a'\''bb\'\''aaa'
test1 'a'\''bb\'\''aaa'\''c'                  'c'
test1 'a"bb'                                  'bb'
test1 'a"bb\"a'                               'bb\"a'
test1 'a"bb\"a"c'                             'a"bb\"a"c'
test1 'a`'                                    'a`'
test1 'a`echo'                                'a`echo'
test1 'a`echo w'                              'w'
test1 'a"echo '                               'echo '
test1 'a"echo w'                              'echo w'
test1 '$'\''a\'\'' x'                         '$'\''a\'\'' x'
test1 'a`bbb ccc`'                            'ccc`'
test1 'a`aa'\''a'                             'a'
test1 'a`aa"aa'                               'aa'
test1 'a`aa$'\''a\'\''a a'                    'a`aa$'\''a\'\''a a'
test1 'a`b$'\''c\'\''d e'                     'a`b$'\''c\'\''d e'
test1 '$'\''c\'\''d e`f g'                    '$'\''c\'\''d e`f g'
test1 '$'\''c\'\''d e'\''f`g h'               'f`g h'
test1 '$'\''a b'\''c`d e'                     'e'
test1 'a`b'\''c'\''d e'                       'e'
test1 'a`b'\''c'\''d e f'                     'f'
test1 'a`$(echo world'                        'world'
test1 'a`$'\''a\'\'' b'                       'a`$'\''a\'\'' b'
test1 'a`$'\''b c\'\''d e$'\''f g\'\'''       'g\'\'''
test1 'a`$'\''b c\'\''d e$'\''f g\'\''h i'    'i'
test1 'a`$'\''b c\'\''d e$'\''f g\'\''h i`j'  'i`j'
test1 'a`$'\''b c\'\''d e'\''f g'\'''         'g'\'''
test1 'a`a;'                                  ''
test1 'a`x='                                  ''
test1 'a`x=y'                                 'y'
test1 'a`b|'                                  ''
test1 'a`b:c'                                 'c'
test1 'a`b&'                                  ''

COMP_WORDBREAKS=@$IFS
gen_wordbreaks
test1 'a`b@c'                                 '@c'

COMP_WORDBREAKS=z$IFS
gen_wordbreaks
test1 'a`b;c'                                 'a`b;c'
test1 'a`bzc'                                 'c'
test1 'a`bzcdze'                              'e'
test1 'a`bzcdzze'                             'e'
test1 'a`bzcdzzze'                            'e'
test1 'a`b\zc'                                'a`b\zc'

COMP_WORDBREAKS='$'$IFS
gen_wordbreaks
test1 'a`b$'\''hxy'\'''                       'a`b$'\''hxy'\'''
test1 'a`b$'                                  '$'
test1 'a`b$x'                                 '$x'
test1 'a`b${'                                 '${'
test1 'a`b${x}'                               '${x}'
test1 'a`b${x}y'                              '${x}y'
test1 'a`b$='                                 '$='
test1 'a`b$.'                                 '$.'
test1 'a`b$'\''a'\'''                         'a`b$'\''a'\'''
test1 'a`b$"a"'                               '$"a"'
test1 'a'\''b'                                'b'
test1 'a`b$'\'''\'' a$'\''xyz'                'xyz'

COMP_WORDBREAKS='\'$IFS
gen_wordbreaks
test1 'a`b\cd'                                'cd'
test1 'a`b\cde\fg'                            'fg'
test1 'a`b\c\\a'                              '\a'
test1 'a`b\c\\\a'                             'a'
test1 'a`b\c\\\\a'                            '\a'
test1 'a`b\c\a\a'                             'a'
test1 'a`b\'                                  ''
test1 'a`b\\'                                 '\'
test1 'a`b\\\'                                ''

COMP_WORDBREAKS='\$'$IFS
gen_wordbreaks
test1 'a`b$\'                                 ''
test1 'a`b\$'                                 '$'

COMP_WORDBREAKS='$z@'$IFS
gen_wordbreaks
test1 'a$z'                                   ''
test1 'a$$z'                                  ''
test1 'a$$'                                   '$'
test1 'a$@'                                   '@'
test1 'a$$@'                                  '@'

COMP_WORDBREAKS='!'$IFS
gen_wordbreaks
test1 'a`b!'                                  ''
test1 'a`b!c'                                 'c'
COMP_WORDBREAKS='#'$IFS
gen_wordbreaks
test1 'a`b#'                                  ''
test1 'a`b#c'                                 'c'
COMP_WORDBREAKS='%'$IFS
gen_wordbreaks
test1 'a`b%'                                  ''
test1 'a`b%c'                                 'c'
COMP_WORDBREAKS='*'$IFS
gen_wordbreaks
test1 'a`b*'                                  ''
test1 'a`b*c'                                 'c'
COMP_WORDBREAKS='+'$IFS
gen_wordbreaks
test1 'a`b+'                                  ''
test1 'a`b+c'                                 'c'
COMP_WORDBREAKS=','$IFS
gen_wordbreaks
test1 'a`b,'                                  ''
test1 'a`b,c'                                 'c'
COMP_WORDBREAKS='-'$IFS
gen_wordbreaks
test1 'a`b-'                                  ''
test1 'a`b-c'                                 'c'
COMP_WORDBREAKS='.'$IFS
gen_wordbreaks
test1 'a`b.'                                  ''
test1 'a`b.c'                                 'c'
COMP_WORDBREAKS='/'$IFS
gen_wordbreaks
test1 'a`b/'                                  ''
test1 'a`b/c'                                 'c'
COMP_WORDBREAKS='?'$IFS
gen_wordbreaks
test1 'a`b?'                                  ''
test1 'a`b?c'                                 'c'
COMP_WORDBREAKS='['$IFS
gen_wordbreaks
test1 'a`b['                                  ''
test1 'a`b[c'                                 'c'
COMP_WORDBREAKS=']'$IFS
gen_wordbreaks
test1 'a`b]'                                  ''
test1 'a`b]c'                                 'c'
COMP_WORDBREAKS='^'$IFS
gen_wordbreaks
test1 'a`b^'                                  ''
test1 'a`b^c'                                 'c'
COMP_WORDBREAKS='_'$IFS
gen_wordbreaks
test1 'a`b_'                                  ''
test1 'a`b_c'                                 'c'
COMP_WORDBREAKS='}'$IFS
gen_wordbreaks
test1 'a`b}'                                  ''
test1 'a`b}c'                                 'c'
COMP_WORDBREAKS='~'$IFS
gen_wordbreaks
test1 'a`b~'                                  ''
test1 'a`b~c'                                 'c'
COMP_WORDBREAKS='`'$IFS
gen_wordbreaks
test1 'a`b`'                                  ''

echo "Passed $pass_count/$test_count cases"
