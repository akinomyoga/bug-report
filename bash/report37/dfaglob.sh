#!/bin/bash

mkdir -p out

if [[ ${KSH_VERSION-} ]]; then
  source ~/.mwg/src/ble.sh/out/lib/benchmark.ksh
  measure() {
    # ksh easily crashes so want to run tests in subshells, but ksh does
    # aggresive optimization so tries to run it in the main shell.  To run the
    # test forcibly in subshells, I here run the test in the midddle process of
    # a pipeline.
    nsec=$(echo | { ble_measure -q "$@"; echo $nsec; } | cat)
    [[ $nsec ]] || nsec=-2
  }
  alias local=typeset
else
  source ~/.mwg/src/ble.sh/src/benchmark.sh
  function measure { ble-measure -q "$@"; }
fi

function fnmatch_measure {
  local pattern=$1 target=$2
  # fnmatch はどうやらクラッシュする様なのでサブシェルの中で実行する
  nsec=$(nsec=-1; measure 'fnmatch "$pattern" "$target"'; echo "$nsec")
  [[ $nsec ]] || nsec=-2
}

test1() {
  local len=$1 nest=$2

  target=$(printf "%*s" "$len" b | sed 's/ /x/g')
  local pattern=x i=
  if [[ $shell == regex ]]; then
    for ((i=0;i<nest;i++)); do
      pattern=$pattern'*'
    done
    measure '[[ $target =~ ^$pattern$ ]]'
  elif [[ $shell == zsh ]]; then
    for ((i=0;i<nest;i++)); do
      pattern='('$pattern')#'
    done
    measure "[[ \$target == $pattern ]]"
  else
    for ((i=0;i<nest;i++)); do
      pattern='*('$pattern')'
    done
    if [[ $shell == fnmatch ]]; then
      fnmatch_measure "$pattern" "$target"
    else
      measure "[[ \$target == $pattern ]]"
    fi
  fi
  ((nsec>=0)) &&
    echo "$len" "$nsec" "$nest"
}

run_test1() {
  local outfile=out/$shell.test1
  [[ -s $outfile ]] && return 0

  local nest len nsec
  for nest in 1 2 3 4 6 8 10; do
    for len in {1..30} 50 {1,2,5}00 {1,2,5}000 {1,2,5}0000 {1,2,5}00000 {1,2,5}000000 {1,2,5}0000000; do
      test1 "$len" "$nest"
      ((nsec<0||nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

test2() {
  local len=$1 type=$2
  target=$(printf "%*s" "$len" '' | sed 's/ /x/g')
  if [[ $shell == @(regex|fnmatch) ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
    case $type in
    (1) measure 'ret=${target%%( )##}' ;;
    (2) measure 'ret=${target##( )##}' ;;
    esac
  else
    case $type in
    (1) measure 'ret=${target%%+( )}' ;;
    (2) measure 'ret=${target##+( )}' ;;
    esac
  fi
  ((nsec >= 0)) &&
    echo "$len" "$nsec" "$type"
}

run_test2() {
  local outfile=out/$shell.test2
  [[ -s $outfile ]] && return 0

  local len type
  for type in 1 2; do
    for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
      test2 "$len" "$type"
      ((nsec<0||nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

# https://lists.gnu.org/archive/html/bug-bash/2022-10/msg00132.html
# https://lists.gnu.org/archive/html/bug-bash/2022-09/msg00008.html
test3() {
  local nline=$1 type=$2 ret
  target=$(yes | head -n "$nline") 2>/dev/null # ksh complains for SIGPIPE
  if [[ $shell == @(regex|fnmatch) ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
    case $type in
    (1) measure "ret=\${target//( )#\$'\n'( )#/\$'\n'}" ;;
    (2) measure "ret=\${target//([\$' \t\n'])##/ }" ;;
    esac
  else
    case $type in
    (1) measure "ret=\${target//*( )\$'\n'*( )/\$'\n'}" ;;
    (2) measure "ret=\${target//+([\$' \t\n'])/ }" ;;
    esac
  fi
  ((nsec >= 0)) &&
    echo "$nline" "$nsec" "$type"
}

run_test3() {
  local outfile=out/$shell.test3
  [[ -s $outfile ]] && return 0

  local type nline nsec
  for type in 1 2; do
    for nline in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
      test3 "$nline" "$type"
      ((nsec<0||nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

# https://lists.gnu.org/archive/html/bug-bash/2022-10/msg00048.html
test4() {
  local len=$1
  target=$(printf '%0*d' "$len" 0)
  if [[ $shell == regex ]]; then
    measure '[[ $target =~ ^0+$ ]]'
  elif [[ $shell == fnmatch ]]; then
    fnmatch_measure "+(0)" "$target"
  elif [[ $shell == zsh ]]; then
    measure '[[ $target == (0)## ]]'
  else
    measure '[[ $target == +(0) ]]'
  fi
  ((nsec >= 0)) &&
    echo "$len" "$nsec"
}

run_test4() {
  local outfile=out/$shell.test4
  [[ -s $outfile ]] && return 0

  local len nsec
  for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
    test4 "$len"
    ((nsec<0||nsec>=5*1000**3)) && break
  done > "$outfile"
}

# https://stackoverflow.com/q/47080621
test5() {
  local nline=$1 ret
  target=$(yes 3.14 | head -n "$nline") 2>/dev/null # ksh complains for SIGPIPE
  if [[ $shell == @(regex|fnmatch) ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
    measure 'ret=${target//([0-9])##.}'
  else
    measure 'ret=${target//+([0-9]).}'
  fi
  ((nsec >= 0)) &&
    echo "$nline" "$nsec"
}

run_test5() {
  local outfile=out/$shell.test5
  [[ -s $outfile ]] && return 0

  local len nsec
  for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
    test5 "$len"
    ((nsec<0||nsec>=5*1000**3)) && break
  done > "$outfile"
}

# https://lists.gnu.org/archive/html/bug-bash/2021-07/msg00065.html
# https://stackoverflow.com/q/57481631/4908404
test6() {
  local len=$1 type=$2
  target=$(printf '%0*d' "$len" 0)
  if [[ $shell == regex ]]; then
    case $type in
    (1) measure '[[ $target =~ ^(|[^x]|...*)+y$ ]]' ;;
    (2) measure '[[ $target =~ ^.**1$ ]]' ;;
    esac
  elif [[ $shell == zsh ]]; then
    case $type in
    (1) measure '[[ $target == (^x)##y ]]' ;;
    (2) measure '[[ $target == (*)#1 ]]' ;;
    esac
  elif [[ $shell == fnmatch ]]; then
    case $type in
    (1) fnmatch_measure "+(!(x))y" "$target" ;;
    (2) fnmatch_measure "*(*)1"    "$target" ;;
    esac
  else
    case $type in
    (1) measure '[[ $target == +(!(x))y ]]' ;;
    (2) measure '[[ $target == *(*)1 ]]' ;;
    esac
  fi
  ((nsec >= 0)) &&
    echo "$len" "$nsec" "$type"
}
run_test6() {
  local outfile=out/$shell.test6
  [[ -s $outfile ]] && return 0

  local type len nsec
  for type in 1 2; do
    for len in $(printf '%s\n' {1..10} {12..30..2} 50 {1,2,5}{00,000,0000,00000,000000,0000000} | sort -n); do
      test6 "$len" "$type"
      ((nsec<0||nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

#------------------------------------------------------------------------------

test7() {
  local len=$1 type=$2
  target=$(printf '%0*d' "$len" 1)
  if [[ $shell == regex ]]; then
    case $type in
    (1) measure '[[ $target =~ ^hello$ ]]' ;;
    (2) measure '[[ $target =~ ^.*a.*b.*c.*$ ]]' ;;
    (3) measure '[[ $target =~ ^0.*0.*0.*0.*0$ ]]' ;;
    esac
  elif [[ $shell == fnmatch ]]; then
    case $type in
    (1) fnmatch_measure "hello"     "$target" ;;
    (2) fnmatch_measure "*a*b*c*"   "$target" ;;
    (3) fnmatch_measure "0*0*0*0*0" "$target" ;;
    esac
  else
    case $type in
    (1) measure '[[ $target == hello ]]' ;;
    (2) measure '[[ $target == *a*b*c* ]]' ;;
    (3) measure '[[ $target == 0*0*0*0*0 ]]' ;;
    esac
  fi
  ((nsec >= 0)) &&
    echo "$len" "$nsec" "$type"
}
run_test7() {
  local outfile=out/$shell.test7
  [[ -s $outfile ]] && return 0

  local type len nsec
  for type in 1 2 3; do
    for len in $(printf '%s\n' {1..10} {12..30..2} 50 {1,2,5}{00,000,0000,00000,000000,0000000} | sort -n); do
      test7 "$len" "$type"
      ((nsec<0||nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

test8() {
  local len=$1 type=$2 ret
  target=$(printf '%*s' "$len" '')
  if [[ $shell == @(regex|fnmatch) ]]; then
    nsec=-1
  elif [[ $shell == zsh ]]; then
    case $type in
    (1) measure 'ret=${target//" "}' ;;
    (2) measure 'ret=${target//" "(x|)}' ;;
    esac
  else
    case $type in
    (1) measure 'ret=${target//" "}' ;;
    (2) measure 'ret=${target//" "?(x)}' ;;
    esac
  fi
  ((nsec >= 0)) &&
    echo "$len" "$nsec" "$type"
}
run_test8() {
  local outfile=out/$shell.test8
  [[ -s $outfile ]] && return 0

  local len type nsec
  for type in 1 2; do
    for len in $(printf '%s\n' {1,2,5}{,0,00,000,0000,00000,000000,0000000} | sort -n); do
      test8 "$len" "$type"
      ((nsec<0||nsec>=5*1000**3)) && break
    done
    echo
  done > "$outfile"
}

function run_for_implementation_type {
  local shell
  if [[ ${ZSH_VERSION-} ]]; then
    # There seems to be no way to get the path of the current zsh binary
    case $1 in
    (zshk)
      setopt kshglob
      shell=zshk ;;
    (*)
      setopt extendedglob
      shell=zsh ;;
    esac
  elif [[ ${KSH_VERSION-} ]]; then
    shell=ksh93
  else
    shopt -s extglob
    shell=${1:-${BASH##*/}}

    if [[ $shell == fnmatch ]]; then
      [[ fnmatch.so -nt fnmatch_builtin.c ]] ||
        gcc -O2 -fPIC -shared -o fnmatch.so fnmatch_builtin.c
      enable -f ./fnmatch.so fnmatch
    fi
  fi

  run_test1
  run_test2
  run_test3
  run_test4
  run_test5
  run_test6
  run_test7
  run_test8
}

function main {
  if [[ $1 == all ]]; then
    ./bash0   "$BASH_SOURCE" bash0
    ./bash2v8 "$BASH_SOURCE" bash2v8
    ./bash2v8 "$BASH_SOURCE" regex
    ./bash2v8 "$BASH_SOURCE" fnmatch
    zsh       "$BASH_SOURCE" zsh
    #zsh      "$BASH_SOURCE" zshk
    ksh93     "$BASH_SOURCE"
    gnuplot dfaglob.gp
  else
    run_for_implementation_type "$@"
  fi
}

main "$@"
