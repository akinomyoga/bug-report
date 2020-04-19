#!/bin/bash

# 2020-04-15

function check7 {
  # inline assignments はどうも
  # previous context として削除される様だ。
  function f1 {
    echo "f1.1: $v"
    unset -v v
    echo "f1.2: $v"
    v=global.modified
    echo "f1.3: $v"
  }

  v=global
  v=inline f1
  echo "g: $v"

  # * local をすると値が変化しない。
  #   という事は inline var はその関数の local と scope を共有している?
  # * 然し、local をしても previous context として削除されてしまう。
  #   この振る舞いは bash-4.3 で変わった。以前は localvar_unset 的な振る舞いだった。
  function f2 {
    echo "f2.1: $v"
    local v
    echo "f2.2: $v"
    unset -v v
    echo "f2.2: $v"
    v=global.modified
    echo "f2.3: $v"
  }

  v=global
  v=inline f2
  echo "g: $v"

  # * inline variable は local で列挙されるかと思ったが列挙されない。
  #   これを見ると local variables ではない様にも思われる。
  function f3 {
    echo "[f3.local]"
    local w=local
    local -p
  }
  v=inline f3

  # Bash のソースコードを観察して気づいたが、
  # もしかして tempenv は如何なる local にも優先されるのか?
  # と思ったがそうでも無いようである。
  # 或いは tempenv は inline assign とは関係ない?
  function f4b {
    local A=f4b
    echo "f4b: A=$A"
  }
  function f4a {
    f4b
    echo "f4a: A=$A"
  }
  A=1 f4a

  # eval を挟んだらどうなるのか。
  # →localvar_unset になっている。
  function f5 {
    local v=f5
    echo "f5.1: $v"
    unset -v v
    echo "f5.2: $v"
  }
  v=global
  v=tempenv eval 'f5; f5'
  v=tempenv eval 'echo "eval.1: $v"; unset -v v; echo "eval.2: $v"'

  # 1. eval の中で tempenv が見える時にはそれを削除する。
  #   eval の中で外側の local を unset すると current-scope unset になっている。
  # 2. "local" による一覧は tempenv をすり抜けて現在の関数の局所変数を列挙する。
  # 3. "declare -p" で列挙した場合には tempenv が引っかかる。
  function f6a {
    echo "[local x tempenv] unset"
    local L=f6a
    L=tempenv eval 'echo "eval.1: $L"; unset -v L; echo "eval.2: $L"; unset -v L; echo "eval.3: $L"'

    echo "[local x tempenv] local"
    local L=f6a
    L=tempenv eval 'local; unset -v L; local; unset -v; local'

    echo "[local x tempenv] declare -p"
    local L=f6a
    L=tempenv eval 'declare -p L; unset -v L; declare -p L; unset -v L; declare -p L'

    echo "[local x tempenv] nested eval"
    local L=f6a
    L=tempenv1 eval '
      echo "eval1.1: $L"
      L=tempenv2 eval "
        echo \"  eval2.1: \$L\"
        unset -v L
        echo \"  eval2.2: \$L\"
        unset -v L
        echo \"  eval2.3: \$L\"
        unset -v L
        echo \"  eval2.4: \$L\"
      "
      echo "eval1.2: $L"
    '
  }
  local L=local
  f6a
}
#check7

check7a() {
  f1() {
    local v=local
    unset -v v # this is local-scope unset
    echo "v: ${v-(unset)}"
  }
  v=global
  v=tempenv f1
}
#check7a

# 改めて bash-dev を用いて振る舞いを調べる。
check7b() {
  unlocal() { unset -v "$1"; }

  f1() {
    local v=local
    unset v
    echo "[$1,local,(unset)] v: ${v-(unset)}"
  }
  v=global
  v=tempenv f1 global,tempenv

  f1() {
    local v=local
    unlocal v
    echo "[$1,local,(unlocal)] v: ${v-(unset)}"
  }
  v=global
  v=tempenv f1 global,tempenv
}
#check7b

# 何と tempenv だけの時は dynamic unset になっている。
check7c() {
  unlocal() { unset -v "$1"; }

  f1() {
    unset v
    echo "[$1,(unset)] v: ${v-(unset)}"
  }
  v=global
  v=tempenv f1 global,tempenv

  f1() {
    unlocal v
    echo "[$1,(unlocal)] v: ${v-(unset)}"
  }
  v=global
  v=tempenv f1 global,tempenv
}
#check7c

check7b.only-local() {
  unlocal() { unset -v "$1"; }

  f1() {
    local v=local
    unset v
    echo "[$1,local,(unset)] v: ${v-(unset)}"
  }
  v=global
  f1 global

  f1() {
    local v=local
    unlocal v
    echo "[$1,local,(unlocal)] v: ${v-(unset)}"
  }
  v=global
  f1 global
}
#check7b.only-local


# やはり tempenv,local は同じ scope に定義されている気がする。
check7d() {
  f1() {
    echo "[$1]: ${v-(unset)}"
    local v
    echo "[$1,local]: ${v-(unset)}"
  }
  v=global
  f1 global
  v=tempenv f1 global,tempenv
}
#check7d

# local -p で何が列挙されるのか
# →tempenv は列挙されない。
check7e() {
  f3() {
    echo "[$1] locals: $(local -p)"
    local v
    echo "[$1] locals: $(local -p)"
  }
  v=global
  f3 global
  v=tempenv f3 global,tempenv
}
#check7e

# eval を挟んでも tempenv/local は同じスコープになるのか。
check7f() {
  unlocal() { unset -v "$1"; }

  f5() {
    echo "[$1] v: ${v-(unset)}"
    local v
    echo "[$1,local] v: ${v-(unset)}"
    ( unset v
      echo "[$1,local+unset] v: ${v-(unset)}" )
    ( unlocal v
      echo "[$1,local+unlocal] v: ${v-(unset)}" )
  }
  v=global
  f5 global
  v=tempenv f5 global,tempenv
  v=tempenv eval 'f5 "global,tempenv,(eval)"'
}
#check7f

# local は tempenv の値を常に継承するのか
check7g() {
  f1() {
    local v
    echo "[$1,(local)] v: ${v-(unset)}"
  }
  f2() {
    f1 "$1,(func)"
  }
  v=global
  v=tempenv f2 global,tempenv
  (export v=global; f2 xglobal)
}
#check7g

# v=tempenv2 eval '...' で関数内に階層を作れるか?
check7h() {
  f1() {
    local v=local1
    echo "[$1,local1] v: ${v-(unset)}"
    v=tempenv2 eval '
      echo "[$1,local1,tempenv2,(eval)] v: ${v-(unset)}"
      local v=local2
      echo "[$1,local1,tempenv2,(eval),local2] v: ${v-(unset)}"
    '
    echo "[$1,local1] v: ${v-(unset)} (after)"
  }
  v=global
  v=tempenv1 f1 global,tempenv1

  # Bash-4.2 以前では以下の結果になる。
  # つまり、tempenv があると local にはアクセスできなくなる。
  #
  # [global,tempenv,local] v: local
  # [global,tempenv,local,tempenv2,(eval)] v: tempenv2
  # [global,tempenv,local,tempenv2,(eval),local] v: tempenv2
  # [global,tempenv,local] v: local2
  #
  # Bash-4.3 以降では以下の様な結果になる。つまり、
  # tempenv,eval によって local にもスコープが作られるという事。
  #
  # [global,tempenv,local] v: local
  # [global,tempenv,local,tempenv2,(eval)] v: tempenv2
  # [global,tempenv,local,tempenv2,(eval),local] v: local2
  # [global,tempenv,local] v: local

  #----------------------------------------------------------------------------
  # これは期待通りの動作である。

  f2() {
    local v=local1
    v=tempenv2 eval '
      local v=local2
      (unset v  ; echo "[$1,local1,tempenv2,(eval),local2,(unset)] v: ${v-(unset)}")
      (unlocal v; echo "[$1,local1,tempenv2,(eval),local2,(unlocal)] v: ${v-(unset)}")
    '
  }
  v=tempenv1 f2 global,tempenv1

  #----------------------------------------------------------------------------
  # unlocal tempenv/local これも期待通りの動作

  f3() {
    local v=local1
    v=tempenv2 eval '
      local v=local2
      v=tempenv3 eval "
        local v=local3
        echo \"[\$1/local1,tempenv2/local2,tempenv3/local3] v: \${v-(unset)}\"
        unlocal v
        echo \"[\$1/local1,tempenv2/local2,tempenv3/local3] v: \${v-(unset)} (unlocal 1)\"
        unlocal v
        echo \"[\$1/local1,tempenv2/local2,tempenv3/local3] v: \${v-(unset)} (unlocal 2)\"
        unlocal v
        echo \"[\$1/local1,tempenv2/local2,tempenv3/local3] v: \${v-(unset)} (unlocal 3)\"
        unlocal v
        echo \"[\$1/local1,tempenv2/local2,tempenv3/local3] v: \${v-(unset)} (unlocal 4)\"
      "
    '
  }
  v=global
  v=tempenv1 f3 global,tempenv1

  #----------------------------------------------------------------------------
  # unlocal tempenv / unset tempenv
  # どうやら tempenv に対しては常に dynamic unset になる様だ。

  f4.unlocal() {
    v=tempenv2 eval '
      v=tempenv3 eval "
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)}\"
        unlocal v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unlocal 1)\"
        unlocal v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unlocal 2)\"
        unlocal v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unlocal 3)\"
        unlocal v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unlocal 4)\"
      "
    '
  }
  v=global
  v=tempenv1 f4.unlocal global,tempenv1

  f4.unset() {
    v=tempenv2 eval '
      v=tempenv3 eval "
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)}\"
        unset v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unset 1)\"
        unset v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unset 2)\"
        unset v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unset 3)\"
        unset v
        echo \"[\$1,tempenv2,tempenv3] v: \${v-(unset)} (unset 4)\"
      "
    '
  }
  v=global
  v=tempenv1 f4.unset global,tempenv1
}
#check7h

# local は tempenv cell があれば其処に変数を定義する。
# 然し、上の階層の関数の tempenv も書き換えてしまう事はあるのだろうか。
# →その様なことはない。唯単に値を継承するだけである。
check7i() {
  f1() { local v=f1.local; echo "[f1] v: ${v-(unset)}"; }
  f2() { v=tempenv eval 'f1; echo "[f2] v: ${v-(unset)}"'; }
  f2

  f1() { local v; echo "[f1] v: ${v-(unset)}"; }
  f2() { v=tempenv eval 'f1; echo "[f2] v: ${v-(unset)}"'; }
  f2
}
#check7i

#                      unset         unlocal
# global,tempenv,local undef         global
# global,tempenv       global        global
# global,local         undef         global

#------------------------------------------------------------------------------

check8() {
  f2() {
    local v=local1
    v=tempenv2 eval '
      local v=local2
      unset v
      echo "[tempenv1/local1,tempenv2/local2,(unset)] v: ${v-(unset)}"'
  }
  v=tempenv1 f2

  f3() {
    local v=local1
    v=tempenv2 eval '
      local v=local2
      v=tempenv3 eval "
        local v=local3
        unset v
        echo \"[tempenv1/local1,tempenv2/local2,tempenv3/local3,(unset)] v: \${v-(unset)}\"
      "
    '
  }
  v=tempenv1 f3
}
check8

# [global,tempenv1,tempenv2,tempenv3] v: tempenv3
# [global,tempenv1,tempenv2,tempenv3] v: (unset) (unlocal 1)
# [global,tempenv1,tempenv2,tempenv3] v: (unset) (unlocal 2)
# [global,tempenv1,tempenv2,tempenv3] v: (unset) (unlocal 3)
# [global,tempenv1,tempenv2,tempenv3] v: (unset) (unlocal 4)
