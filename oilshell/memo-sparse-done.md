# 2025-03-03

### BashArray, SparseArray 検索

```bash
$ git grep -En '(Bash|Sparse)Array' > memo1.md
```

276 行存在する。

### Later: これは list initializer の処理に関係する

これは最終的に BashArray を SparseArray に置き換える時に書き換える。もしくは
BashArray と SparseArray が混在しても良いのではないかという気もする。

例えば osh の中では BashArray が引数リストに対しても使われている様である。実際
の所、配列と引数リストが同じ内部表現を持っている必要はない。むしろ Bash では異
なる実装になっていたはず。

```
builtin/assign_osh.py:305:    if flag_a and rval is not None and rval.tag() != value_e.BashArray:
builtin/assign_osh.py:311:        if rval.tag() == value_e.BashArray:
builtin/assign_osh.py:312:            array_val = cast(value.BashArray, rval)
builtin/assign_osh.py:315:                #return value.BashArray([])
builtin/assign_osh.py:348:                    rval = value.BashArray([])  # type: value_t
```

### "a=value; declare -a a" で変数の内容が消える

```bash
$ bash -c 'a=1234; declare -a a; declare -p a'
declare -a a=([0]="1234")
$ bin/osh -c 'a=1234; declare -a a; declare -p a'
declare -a a=()
```

これは報告した。

### SparseArray なら arr+=([1000]=a [1001]=b) ができて良い筈だが

現在の osh のルールだとこの形式は辞書ということに決まっているので末尾に追記する
しかない。或いは右辺が辞書の場合には算術式評価を実施する? それも一つの手だが、
それは osh のポリシーに真っ向から反対する気がする。

更に以下の様に混在した指定にも osh は対応していないだろう (bash は少なくとも
3.0 で既に対応していて現在と振る舞いは変わらない)。

```bash
a=([1000]=1234 world test)
```

```bash
$ bash -c 'a=([1000]=1234 world test); declare -p a'
declare -a a=([1000]="1234" [1001]="world" [1002]="test")
$ bin/osh -c 'a=([1000]=1234 world test); declare -p a'
  a=([1000]=1234 world test); declare -p a
                 ^~~~~
[ -c flag ]:1: Expected associative array pair
[ble: usage_error (2)]
```

### Later: COMP_ARGV はユーザーが設定する類の物なのだろうか?

```
builtin/completion_osh.py:458:        if val.tag() != value_e.BashArray:
builtin/completion_osh.py:460:        comp_argv = cast(value.BashArray, val).strs
core/completion.py:631:        if val.tag() != value_e.BashArray:
core/completion.py:639:        array_val = cast(value.BashArray, val)
```

現在の変数から読み取って使っている? 然し、説明を読む限りはユーザーが指定する物
ではなく osh の側で提供するものでは。或いはユーザーがその内容を修正することを許
している? それとも他に保存しておく場所を用意するのが面倒だから横着して state の
中に保存しているだけ?

うーん。これも最終的に置換する時に処理すれば良いだろう。

### func_misc

これは SparseArray の実験用の実装なので余り気にしなくて良い。最終的には削除する
ことになるのでは。

```
builtin/func_misc.py:609:class BashArrayToSparse(vm._Callable):
builtin/func_misc.py:611:    value.BashArray -> value.SparseArray, for testing
builtin/func_misc.py:621:        strs = rd.PosBashArray()
builtin/func_misc.py:633:        return value.SparseArray(d, max_index)
builtin/func_misc.py:638:    All ops on value.SparseArray, for testing performance
builtin/func_misc.py:648:        sp = rd.PosSparseArray()
builtin/func_misc.py:721:            return value.BashArray(items)
builtin/func_misc.py:728:            # TODO: return SparseArray
builtin/func_misc.py:729:            return value.BashArray(items)
builtin/func_misc.py:764:            # TODO: return SparseArray
builtin/func_misc.py:765:            return value.BashArray(items2)
builtin/func_misc.py:768:            strs = rd.PosBashArray()
builtin/func_misc.py:770:            # TODO: We can maintain the max index in the value.SparseArray(),
builtin/func_misc.py:793:            print('Invalid SparseArray operation %r' % op_name)
core/shell.py:941:    _AddBuiltinFunc(mem, '_a2sp', func_misc.BashArrayToSparse())
```

### Later: これはテスト用のコード?

```
core/completion_test.py:797:            self.assertEqual(value_e.BashArray, val.tag(),
```

よく分からないが BashArray の実装を取り替えた今、別に何もエラーが出ていないので
OK だろう。

### Later: 新しい配列の作成

```
core/state.py:2028:        new_value = value.BashArray(items)
core/state.py:2078:                return value.BashArray(strs2)
core/state.py:2097:                return value.BashArray(groups)
core/state.py:2121:                return value.BashArray(strs)  # TODO: Reuse this object too?
core/state.py:2154:                return value.BashArray(strs)  # TODO: Reuse this object too?
core/state.py:2173:                return value.BashArray(strs)  # TODO: Reuse this object too?
core/state.py:2686:    BuiltinSetValue(mem, location.LName(name), value.BashArray(a))
core/state.py:2701:    mem.SetNamed(location.LName(name), value.BashArray(a), scope_e.GlobalOnly)
core/state_test.py:192:                     value.BashArray(['1', '2', '3']), scope_e.GlobalOnly)
core/state_test.py:247:                mem.SetValue(lhs, value.BashArray(['x', 'y', 'z']),
```

これは配列を BashArray から SparseArray に切り替える時に書き換える。

### Later: Documentation

```
doc/interpreter-state.md:177:- OSH has `value.BashArray`, and YSH has `value.List`.
doc/ref/chap-osh-assign.md:40:Their type is [BashArray][].
doc/ref/chap-osh-assign.md:44:[BashArray]: chap-type-method.html#BashArray
doc/ref/chap-type-method.md:27:### BashArray
doc/ref/toc-osh.md:50:  [OSH]           BashArray   BashAssoc
doc/types.md:54:- `BashArray BashAssoc` - flat
doc/ysh-tour.md:1419:  - OSH has types `Str BashArray BashAssoc`, and flags `readonly export
```

これらは適切に更新した気がする。もしくは今までのままで良いものなど。

### word_eval: SparseArray operations

```
osh/word_eval.py:111:    if val.tag() == value_e.BashArray:
osh/word_eval.py:112:        array_val = cast(value.BashArray, val)
```

decay: これは `$arr` が `${arr[0]}` になるということ。

SparseArray TODO

```
osh/word_eval.py:227:        elif case(value_e.BashArray):
osh/word_eval.py:228:            val = cast(value.BashArray, UP_val)
```

TODO SparseArray

疑問 そもそもここに BashAssoc が来ることはあるのか?

```
osh/word_eval.py:380:        elif case(value_e.BashArray):  # Slice array entries.
osh/word_eval.py:381:            val = cast(value.BashArray, UP_val)
osh/word_eval.py:417:            raise error.TypeErr(val, 'Slice op expected Str or BashArray',
```

これは `${a[@]:offset:length}` の実装

SparseArray TODO

### word_eval: ${a[@]-default} and array with an empty element a=("")

うーん。ここにも osh のバグがある。

```console
$ bash -c 'a=(""); echo ${a[@]:-world}'
world
$ bin/osh -c 'a=(""); echo ${a[@]:-world}'

$ bash -c 'a=(""); echo ${a[@]-world}'

$ bin/osh -c 'a=(""); echo ${a[@]-world}'

$
```

2025-03-03 これは今試したら直っている。修正を提出した気がする。

### word_eval: InternalStringArray

この辺りは SparseArray に切り替える? でも一時的な配列だし FlatArray で良い気がする。


```
osh/word_eval.py:641:            elif case(value_e.BashArray):
osh/word_eval.py:642:                val = cast(value.BashArray, UP_val)
```

### word_eval

```
osh/word_eval.py:790:            elif case(value_e.BashArray):
osh/word_eval.py:791:                val = cast(value.BashArray, UP_val)
```

Length これは処理済みである。

```
osh/word_eval.py:798:            elif case(value_e.SparseArray):
osh/word_eval.py:799:                val = cast(value.SparseArray, UP_val)
osh/word_eval.py:808:                    val, "Length op expected Str, BashArray, BashAssoc", token)
osh/word_eval.py:818:            if case(value_e.BashArray):
osh/word_eval.py:819:                val = cast(value.BashArray, UP_val)
osh/word_eval.py:826:                return value.BashArray(indices)
osh/word_eval.py:833:                return value.BashArray(val.d.keys())
```

これは GetKeys() を実装する必要がある。

Done `BashArray_GetKeys`, `BashAssoc_GetKeys`
ToDo `SparseArray_GetKeys` は既に存在している。これを呼び出す様にする


```
osh/word_eval.py:856:            elif case(value_e.BashArray):  # caught earlier but OK
```

ToDo SparseArray これは単に case に value_e.SparseArray を追加すれば良いだけ。


```
osh/word_eval.py:887:                elif case(value_e.BashArray):
osh/word_eval.py:888:                    val = cast(value.BashArray, UP_val)
osh/word_eval.py:896:                    new_val = value.BashArray(strs)
osh/word_eval.py:905:                    new_val = value.BashArray(strs)
osh/word_eval.py:909:                        val, 'Unary op expected Str, BashArray, BashAssoc',
```

GetValues: これは `${a[@]%etc}` この辺りは GetValues を使えば済むことである。と
ころで GetValues を実装する為には BashAssoc の slice を先に終わらせる必要がある?
もしくは、GetValues の commit とこれらの単純な書き換えの commit をまとめて、そ
の後で BashAssoc の実装を提供する様にするのが良い?


```
osh/word_eval.py:952:            elif case2(value_e.BashArray):
osh/word_eval.py:953:                array_val = cast(value.BashArray, val)
osh/word_eval.py:958:                val = value.BashArray(strs)
osh/word_eval.py:965:                val = value.BashArray(strs)
osh/word_eval.py:969:                    val, 'Pat Sub op expected Str, BashArray, BashAssoc',
```

GetValues: これは `${a[@]:offset:length}` であり、これも GetValues で一緒に適用
すれば良い。

```
osh/word_eval.py:1000:                    elif case2(value_e.BashArray):
osh/word_eval.py:1001:                        val = value.BashArray([])
```

何らかのエラー処理。これは何?

```
osh/word_eval.py:1031:                elif case(value_e.BashArray):
osh/word_eval.py:1032:                    array_val = cast(value.BashArray, UP_val)
```

これは `${a[@]@Q}` であるが、そもそも BashAssoc 対応していないし、それから穴の
空いている配列に対してクラッシュするのではないか?

ToDo: BashAssoc に対応する

GetValues: これも BashAssoc 対応した後に適用する → と思ったが先に GetValues に
移行することにする。


```
osh/word_eval.py:1045:                if case(value_e.BashArray):
```

SparseArray: これは単に追加すれば良いだけ。

```
osh/word_eval.py:1077:                        val = self._EmptyBashArrayOrError(part.token)
osh/word_eval.py:1081:                elif case2(value_e.BashArray):
osh/word_eval.py:1090:                        val = self._EmptyBashArrayOrError(part.token)
osh/word_eval.py:1094:                elif case2(value_e.BashArray):
```

GetValues: BashAssoc: ここは BashAssoc についてもちゃんと列挙してスキップするべ
きである。というか、これも Getvalues の修正に一緒に含めるのが良い気がする。取り
敢えず commit は作成した。

```
osh/word_eval.py:1118:            elif case2(value_e.BashArray):
osh/word_eval.py:1119:                array_val = cast(value.BashArray, UP_val)
osh/word_eval.py:1147:                                    'Index op expected BashArray, BashAssoc',
```

これは既に BashArray, BashAssoc については良い。BashAssoc_GetElement を追加する
commit で対応している。

SparseArray については別に対応する必要がある。

```
osh/word_eval.py:1190:        # type: (value.BashArray) -> value.Str
osh/word_eval.py:1192:        assert val.tag() == value_e.BashArray, val
```

これは `$*` を連結して一つの文字列にするのに使われている。BashArray 決め打ちな
のは、これは変数の値としての BashArray ではなくて、中間形式の単語列としての
BashArray だからである。うーん。最終的にこの意味での BashArray を残すのかどうか
というのは疑問である。中間形式の単語列まで SparseArray に置き換えるのは違う気が
する。まあ、何れにしてもそういう事は SparseArray に完全に対応してから考えること
にすれば良い。恐らくこの部分は変更しないのが正しい。

```
osh/word_eval.py:1209:    def _EmptyBashArrayOrError(self, token):
osh/word_eval.py:1215:            return value.BashArray([])
```

これも内部 BashArray なのでそのままで良い。

```
osh/word_eval.py:1234:                    val.tag() in (value_e.BashArray, value_e.BashAssoc) and
```

これは SparseArray を追加するだけ。

```
osh/word_eval.py:1370:                    # Do the _EmptyStrOrError/_EmptyBashArrayOrError up front, EXCEPT in
```

これはただのコメントなので気にしない。そもそも言及されているのも BashArray では
なくて _EmptyBashArrayOrError であり、これは unset var の decay 結果としての値
を生成する為の関数なので、値としての BashArray とは関係がない。

```
osh/word_eval.py:1461:        if val.tag() == value_e.BashArray:
osh/word_eval.py:1462:            array_val = cast(value.BashArray, UP_val)
```

うーん。これも内部表現の BashArray であってここには SparseArray は到達しない気
がする。

```
osh/word_eval.py:1526:            if val.tag() in (value_e.BashArray, value_e.BashAssoc):
```

SparseArray を単に追加するだけ

```
osh/word_eval.py:1545:        if val.tag() == value_e.BashArray:
osh/word_eval.py:1546:            array_val = cast(value.BashArray, UP_val)
```

これもやはり内部表現の BashArray の気がする。

```
osh/word_eval.py:1960:                return value.BashArray(strs)
```

これは全て InitializerList になる様に変換する場所なのでこの条件分岐自体不要にな
る。

```
osh/word_eval.py:2253:          allow_assign: True for command.Simple, False for BashArray a=(1 2 3)
```

これは何だか分からないがただのコメントなので気にしない事にする。

### Later: `ysh/expr_eval`: コメント内の BashArray ?

これは何れにしても BashArray から SparseArray に switch する時に一緒に置き換え
る物の気がする。

```
ysh/expr_eval.py:1224:                #return value.BashArray(strs)
```

### BashArray / SparseArray -> BashDenseArray / BashSparseArray 等の様に改名?

別に BashArray を削除する必要もない気がする。のだとしたらもっと分かりやすい名前
にして良いのでは。

### Tests

テスト自体は実装には関係ないだろうか、一方で BashArray と同様のテストを
SparseArray に対しても実行するべきではという話である。とは言っても最終的に
BashArray を SparseArray に置き換えるのだとしたらそのままでも良い。最終的に
BashArray を SparseArray に置換すれば良い。

```
demo/sparse-array.sh:14:#   core/value.asdl defines value.{BashArray,SparseArray}
demo/sparse-array.sh:43:  echo $osh SparseArray
demo/sparse-array.sh:115:  # Populate SparseArray 0 .. n-1
demo/sparse-array.sh:142:    # Slice to BashArray
spec/array-compat.test.sh:106:#### value.BashArray internal representation - Indexed
spec/array-compat.test.sh:159:#### value.BashArray internal representation - Assoc (ordering is a problem)
spec/ble-idioms.test.sh:175:# TODO: more BashArray idioms / stress tests ?
spec/ble-idioms.test.sh:273:#### SparseArray Performance demo
spec/ble-idioms.test.sh:316:SparseArray
spec/ble-idioms.test.sh:336:#### test that length works after conversion to SparseArray
spec/ysh-builtin-meta.test.sh:254:array = (Cell exported:F readonly:F nameref:F val:(value.BashArray strs:[_ _ _ 42]))
spec/ysh-builtin-meta.test.sh:300:#### pp test_ supports BashArray, BashAssoc
spec/ysh-builtin-meta.test.sh:317:{"type":"BashArray","data":{"0":"a","1":"b","2":"c"}}
spec/ysh-builtin-meta.test.sh:318:{"type":"BashArray","data":{"0":"a","1":"b","2":"c","5":"z"}}
spec/ysh-builtins.test.sh:3:#### append onto BashArray a=(1 2)
spec/ysh-expr-bool.test.sh:162:#### or BashArray, or BashAssoc
spec/ysh-expr-bool.test.sh:170:{"type":"BashArray","data":{"0":"1","1":"2","2":"3"}}
spec/ysh-expr.test.sh:29:#### Length doesn't apply to BashArray
spec/ysh-json.test.sh:1205:#### BashArray can be serialized
spec/ysh-json.test.sh:1217:  "type": "BashArray",
spec/ysh-json.test.sh:1221:  "type": "BashArray",
spec/ysh-printing.test.sh:86:#### SparseArray, new representation for bash array
spec/ysh-printing.test.sh:110:(SparseArray)
spec/ysh-printing.test.sh:111:(SparseArray [0]='hello' [5]='5')
spec/ysh-printing.test.sh:113:(Dict)  {k: (SparseArray)}
spec/ysh-printing.test.sh:114:(Dict)  {k: (SparseArray [0]='hello' [5]='5')}
spec/ysh-printing.test.sh:116:{"type":"SparseArray","data":{}}
spec/ysh-printing.test.sh:117:{"type":"SparseArray","data":{"0":"hello","5":"5"}}
spec/ysh-printing.test.sh:119:(Dict)   {"k":{"type":"SparseArray","data":{}}}
spec/ysh-printing.test.sh:120:(Dict)   {"k":{"type":"SparseArray","data":{"0":"hello","5":"5"}}}
spec/ysh-printing.test.sh:123:#### BashArray, short
spec/ysh-printing.test.sh:143:(BashArray)
spec/ysh-printing.test.sh:144:(BashArray 'hello')
spec/ysh-printing.test.sh:146:(Dict)  {k: (BashArray)}
spec/ysh-printing.test.sh:147:(Dict)  {k: (BashArray 'hello')}
spec/ysh-printing.test.sh:149:{"type":"BashArray","data":{}}
spec/ysh-printing.test.sh:150:{"type":"BashArray","data":{"0":"hello"}}
spec/ysh-printing.test.sh:152:(Dict)   {"k":{"type":"BashArray","data":{}}}
spec/ysh-printing.test.sh:153:(Dict)   {"k":{"type":"BashArray","data":{"0":"hello"}}}
spec/ysh-printing.test.sh:156:#### BashArray, long
spec/ysh-printing.test.sh:165:(BashArray 'world' null '*.py')
spec/ysh-printing.test.sh:166:(BashArray
spec/ysh-with-sh.test.sh:174:# TODO: Should print this like this bash, with value.BashArray
```

## ToDo: InitializerList

- BashArray_ToStrForShellPrint の第二引数は不要になる。

<!-- ====================================================================== -->
# 2025-01-03

整理しようと思ったがやはり `word_eval` 周りが処理待ちなのでその後で `word_eval`
を確認する必要がある。それを待っている間にどうでもいい部分を修正して提出するの
が良い気がする。

### BUG: s+=assoc でクラッシュする

```bash
$ bin/osh -c 's=str; s+=(["hello"]=1)'
```

これは修正するにしてもどの様に修正するかは謎である。単にエラーを出力する様にす
る?

### BUG `x+=([0]+=A)` でクラッシュする

```
$ bash -c 'x=(1 2 3); x+=([0]+=A); declare -p x'
declare -a x=([0]="1A" [1]="2" [2]="3")
$ bin/osh -c 'x=(1 2 3); x+=([0]+=A); declare -p x'
Traceback (most recent call last):
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 201, in <module>
    sys.exit(main(sys.argv))
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 170, in main
    return AppBundleMain(argv)
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 140, in AppBundleMain
    return shell.Main('osh', arg_r, environ, login_shell, loader, readline)
  File "/home/murase/.mwg/git/oilshell/oil/core/shell.py", line 1211, in Main
    cmd_flags=cmd_eval.IsMainProgram)
  File "/home/murase/.mwg/git/oilshell/oil/core/main_loop.py", line 375, in Batch
    is_return, is_fatal = cmd_ev.ExecuteAndCatch(node, cmd_flags)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 2103, in ExecuteAndCatch
    status = self._Execute(node)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1740, in _Dispatch
    status = self._ExecuteList(node.children)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1979, in _ExecuteList
    status = self._Execute(child)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1647, in _Dispatch
    status = self._Execute(node.child)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1639, in _Dispatch
    status = self._DoShAssignment(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 988, in _DoShAssignment
    val = PlusEquals(old_val, rhs)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 242, in PlusEquals
    raise AssertionError()  # parsing should prevent this
AssertionError
```

うーん。これは InitializerList 実装時に対応する? それともそれよりも前に修正して
おく? 結局動作を変えない様に修正するのと動作を変更するのは分離したいから先に修
正しておいた方が良い気がする。

### Done: これらは内部実装に触っているので bash_impl に移動しても良いのでは

それぞれコマンドラインからリクエストした時と、何らかの pretty-print の機能で利
用される関数? 然し、serialiation の種類が沢山あるのは何だか変な感じがする。実装
を統合したい様な気がする。まあ、これは後で良い。

```
data_lang/j8.py:350:        self.buf.write(type_str)  # "BashArray",  or "BashAssoc",
data_lang/j8.py:364:    def _PrintSparseArray(self, val, level):
data_lang/j8.py:365:        # type: (value.SparseArray, int) -> None
data_lang/j8.py:367:        self._PrintBashPrefix('"SparseArray",', level)
data_lang/j8.py:398:    def _PrintBashArray(self, val, level):
data_lang/j8.py:399:        # type: (value.BashArray, int) -> None
data_lang/j8.py:401:        self._PrintBashPrefix('"BashArray",', level)
data_lang/j8.py:597:            elif case(value_e.SparseArray):
data_lang/j8.py:598:                val = cast(value.SparseArray, UP_val)
data_lang/j8.py:599:                self._PrintSparseArray(val, level)
data_lang/j8.py:601:            elif case(value_e.BashArray):
data_lang/j8.py:602:                val = cast(value.BashArray, UP_val)
data_lang/j8.py:603:                self._PrintBashArray(val, level)
display/pp_value.py:29:    """Returns a user-facing string like Int, Eggex, BashArray, etc."""
display/pp_value.py:311:        # (BashArray)   (BashArray $'\\')
display/pp_value.py:345:    def _BashArray(self, varray):
display/pp_value.py:346:        # type: (value.BashArray) -> MeasuredDoc
display/pp_value.py:347:        type_name = self._Styled(self.type_style, UText("BashArray"))
display/pp_value.py:376:    def _SparseArray(self, val):
display/pp_value.py:377:        # type: (value.SparseArray) -> MeasuredDoc
display/pp_value.py:378:        type_name = self._Styled(self.type_style, UText("SparseArray"))
display/pp_value.py:473:            elif case(value_e.SparseArray):
display/pp_value.py:474:                sparse = cast(value.SparseArray, val)
display/pp_value.py:475:                return self._SparseArray(sparse)
display/pp_value.py:477:            elif case(value_e.BashArray):
display/pp_value.py:478:                varray = cast(value.BashArray, val)
display/pp_value.py:479:                return self._BashArray(varray)
```

### Done: `ysh/val_opts`: 各種対応

一つ目は `@[sp]` `@sp` である。二つ目は `Bool(sp)` らしい (後で確認が必要)。三
つ目は `$[sp1 == sp2]` の比較に使う (後で確認が必要)。

```bash
ysh/val_ops.py:177:        elif case2(value_e.BashArray):
ysh/val_ops.py:178:            val = cast(value.BashArray, UP_val)
ysh/val_ops.py:353:        elif case(value_e.BashArray):
ysh/val_ops.py:354:            val = cast(value.BashArray, UP_val)
ysh/val_ops.py:422:        elif case(value_e.BashArray):
ysh/val_ops.py:423:            left = cast(value.BashArray, UP_left)
ysh/val_ops.py:424:            right = cast(value.BashArray, UP_right)
```

### Done: JSON 出力の実装? BashArray/BashAssoc についてもちゃんとは実装されていないが。。。

```
core/state.py:652:        #   - although BashArray and BashAssoc may need 'type' tags
core/state.py:662:            elif case(value_e.Str, value_e.BashArray, value_e.BashAssoc):
```

### Done: YSH list->append()?

```
builtin/pure_ysh.py:216:            if case(value_e.BashArray):
builtin/pure_ysh.py:217:                val = cast(value.BashArray, UP_val)
builtin/pure_ysh.py:225:                raise error.TypeErr(val, 'expected List or BashArray',
```

# 2024-12-08

順次提出している途中であるが、一通り確認したので一旦整理する。

### Done: assoc+=([key]=value) が実装されていない

```bash
$ bash -c 'declare -A as=([hello]=1); as+=([world]=2); declare -p as'
declare -A as=([hello]="1" [world]="2" )
$ bin/osh -c 'declare -A as=([hello]=1); as+=([world]=2); declare -p as'
declare -A as=(['world']=2)
```

InitializerList で対応しようと思っていたが、今確認したらこれは既に実装していた。

### Done: `${@:begin:length}` の begiin は BigInt

- ${@:begin:length} `begin` は int で良いのか? 本当は BigInt にするべきである。


### OK: `vendor/souffle/datastructure/Brie.h`

これは恐らく関係ないので無視する。

```
vendor/souffle/datastructure/Brie.h:136: * Iterator type for `souffle::SparseArray`.
vendor/souffle/datastructure/Brie.h:138:template <typename SparseArray>
vendor/souffle/datastructure/Brie.h:139:struct SparseArrayIter {
vendor/souffle/datastructure/Brie.h:140:    using Node = typename SparseArray::Node;
vendor/souffle/datastructure/Brie.h:141:    using index_type = typename SparseArray::index_type;
vendor/souffle/datastructure/Brie.h:142:    using array_value_type = typename SparseArray::value_type;
vendor/souffle/datastructure/Brie.h:146:    SparseArrayIter() = default;  // default constructor -- creating an end-iterator
vendor/souffle/datastructure/Brie.h:147:    SparseArrayIter(const SparseArrayIter&) = default;
vendor/souffle/datastructure/Brie.h:148:    SparseArrayIter& operator=(const SparseArrayIter&) = default;
vendor/souffle/datastructure/Brie.h:150:    SparseArrayIter(const Node* node, value_type value) : node(node), value(std::move(value)) {}
vendor/souffle/datastructure/Brie.h:152:    SparseArrayIter(const Node* first, index_type firstOffset) : node(first), value(firstOffset, 0) {
vendor/souffle/datastructure/Brie.h:165:    bool operator==(const SparseArrayIter& other) const {
vendor/souffle/datastructure/Brie.h:172:    bool operator!=(const SparseArrayIter& other) const {
vendor/souffle/datastructure/Brie.h:187:    SparseArrayIter& operator++() {
vendor/souffle/datastructure/Brie.h:190:        index_type x = value.first & SparseArray::INDEX_MASK;
vendor/souffle/datastructure/Brie.h:195:        } while (x < SparseArray::NUM_CELLS && node->cell[x].value == array_value_type());
vendor/souffle/datastructure/Brie.h:198:        if (x < SparseArray::NUM_CELLS) {
vendor/souffle/datastructure/Brie.h:200:            value.first = (value.first & ~SparseArray::INDEX_MASK) | x;
vendor/souffle/datastructure/Brie.h:210:        x = SparseArray::getIndex(brie_element_type(value.first), level);
vendor/souffle/datastructure/Brie.h:215:            while (x < SparseArray::NUM_CELLS) {
vendor/souffle/datastructure/Brie.h:223:            if (x < SparseArray::NUM_CELLS) {
vendor/souffle/datastructure/Brie.h:226:                value.first &= SparseArray::getLevelMask(level + 1);
vendor/souffle/datastructure/Brie.h:227:                value.first |= x << (SparseArray::BIT_PER_STEP * level);
vendor/souffle/datastructure/Brie.h:236:                x = SparseArray::getIndex(brie_element_type(value.first), level);
vendor/souffle/datastructure/Brie.h:260:    SparseArrayIter operator++(int) {
vendor/souffle/datastructure/Brie.h:275:        out << "SparseArrayIter(" << node << " @ (" << value.first << ", " << value.second << "))";
vendor/souffle/datastructure/Brie.h:278:    friend std::ostream& operator<<(std::ostream& out, const SparseArrayIter& iter) {
vendor/souffle/datastructure/Brie.h:323:class SparseArray {
vendor/souffle/datastructure/Brie.h:325:    friend struct detail::brie::SparseArrayIter;
vendor/souffle/datastructure/Brie.h:327:    using this_t = SparseArray<T, BITS, merge_op, copy_op>;
vendor/souffle/datastructure/Brie.h:403:    SparseArray() : unsynced(RootInfo{nullptr, 0, 0, nullptr, std::numeric_limits<index_type>::max()}) {}
vendor/souffle/datastructure/Brie.h:410:    SparseArray(const SparseArray& other)
vendor/souffle/datastructure/Brie.h:424:    SparseArray(SparseArray&& other)
vendor/souffle/datastructure/Brie.h:436:    ~SparseArray() {
vendor/souffle/datastructure/Brie.h:445:    SparseArray& operator=(const SparseArray& other) {
vendor/souffle/datastructure/Brie.h:469:    SparseArray& operator=(SparseArray&& other) {
vendor/souffle/datastructure/Brie.h:1026:    void addAll(const SparseArray& other) {
vendor/souffle/datastructure/Brie.h:1080:    using iterator = SparseArrayIter<this_t>;
vendor/souffle/datastructure/Brie.h:1499: * Iterator type for `souffle::SparseArray`. It enumerates the indices set to 1.
vendor/souffle/datastructure/Brie.h:1638:    using data_store_t = SparseArray<value_t, BITS, merge_op>;
vendor/souffle/datastructure/Brie.h:2471:    using store_type = SparseArray<nested_trie_type*,
vendor/souffle/datastructure/Brie.h:3060:struct iterator_traits<SparseArrayIter<A>>
vendor/souffle/datastructure/Brie.h:3061:        : forward_non_output_iterator_traits<typename SparseArrayIter<A>::value_type> {};
```

### Done: 算術式における要素アクセス

```
osh/sh_expr_eval.py:141:            array_val = None  # type: value.BashArray
osh/sh_expr_eval.py:144:                    array_val = value.BashArray([])
osh/sh_expr_eval.py:145:                elif case2(value_e.BashArray):
osh/sh_expr_eval.py:146:                    tmp = cast(value.BashArray, UP_val)
osh/sh_expr_eval.py:513:        if (val.tag() in (value_e.BashArray, value_e.BashAssoc) and
osh/sh_expr_eval.py:517:                if val.tag() == value_e.BashArray:
osh/sh_expr_eval.py:524:        #if val.tag() == value_e.BashArray:
osh/sh_expr_eval.py:544:        if (val.tag() in (value_e.BashArray, value_e.BashAssoc) and
osh/sh_expr_eval.py:563:          List[int] for BashArray
osh/sh_expr_eval.py:729:                        if case(value_e.BashArray):
osh/sh_expr_eval.py:730:                            array_val = cast(value.BashArray, UP_left)
osh/sh_expr_eval.py:1016:            if case(value_e.BashArray):
osh/sh_expr_eval.py:1017:                val = cast(value.BashArray, UP_val)
osh/sh_expr_eval.py:1025:                            '-v got BashArray and invalid index %r' %
osh/sh_expr_eval.py:1050:                    raise error.TypeErr(val, 'Expected BashArray or BashAssoc',
```

取り敢えず `[[ -v sp[i] ]]` は動く様になった。

`"${sp[i]}"` は動かないがこれは word_eval がエラーメッセージを発しているのでそ
ちらで対応する必要があるのだろう。じゃあ、こちらの変更は何なのだろう? これは後
回しで PR submit する事にすれば良い。もし `word_eval` だけで駄目だったら
`word_eval` の方の偏光を先に submit しようとした時点で気付くだろう。

* ok: 然し、負の index は本当に `max_index` を基準に取得して良いのか? bash の実
  装だと存在する要素の内での後ろからの順番だったりしないか? → 動作を確認してみ
  たところ少なくとも `bash-5.3-alpha` では `max_index` からの距離で要素を参照し
  ている。

### Fixed: 現在 `*_GetElement` では不正な index が指定された時のエラーを発しない

これで良いのだろうか? これは前述の unset a[-10] や a[-10]=x と同じ問題なのでま
とめて報告するべきである。

### Done: `osh/sh_expr_eval` _IsDefined が負の index に対応していない

```
$ bash -c 'a=(1 2 3); [[ -v "a[-1]" ]]'
$ bin/osh -c 'a=(1 2 3); [[ -v "a[-1]" ]]'
[ble: EXIT_FAILURE (1)]
```

### OK これらは何だろう?

これらはかなり機械的な内容で内部実装に依存していない。そのままで大丈夫のはず。

```
frontend/typed_args.py:285:    def _ToBashArray(self, val):
frontend/typed_args.py:287:        if val.tag() == value_e.BashArray:
frontend/typed_args.py:288:            return cast(value.BashArray, val).strs
frontend/typed_args.py:291:                            'Arg %d should be a BashArray' % self.pos_consumed,
frontend/typed_args.py:294:    def _ToSparseArray(self, val):
frontend/typed_args.py:295:        # type: (value_t) -> value.SparseArray
frontend/typed_args.py:296:        if val.tag() == value_e.SparseArray:
frontend/typed_args.py:297:            return cast(value.SparseArray, val)
frontend/typed_args.py:300:            val, 'Arg %d should be a SparseArray' % self.pos_consumed,
frontend/typed_args.py:449:    def PosBashArray(self):
frontend/typed_args.py:452:        return self._ToBashArray(val)
frontend/typed_args.py:454:    def PosSparseArray(self):
frontend/typed_args.py:455:        # type: () -> value.SparseArray
frontend/typed_args.py:457:        return self._ToSparseArray(val)
```

### Done: mylib のコメント。SparseArray であるべきところが BashArray になっていたのを修正

```
mycpp/gc_mylib.cc:48:// For BashArray
mycpp/mylib.py:109:# For SparseArray
```

### Fixed: BUG BashArray sparse の時に unset a[] をしても None 要素が残るのでは

そもそも sparse の時の "${#arr[@]}" の値も BashArray では異なる

### Done: unset sp[i]

```
core/state.py:2281:                if val.tag() != value_e.BashArray:
core/state.py:2284:                val = cast(value.BashArray, UP_val)
```

### Done: これは別にOK

```
core/value.asdl:105:  | BashArray(List[str] strs)
core/value.asdl:108:  | SparseArray(Dict[BigInt, str] d, BigInt max_index)
```


### Done: 要素代入 sp[0]=1234

```
core/state.py:1969:                    elif case2(value_e.BashArray):
core/state.py:1970:                        cell_val = cast(value.BashArray, UP_cell_val)
```

### Done: `set -x` で SparseArray も表示する

```
core/dev.py:213:        elif case(value_e.BashArray):
core/dev.py:214:            val = cast(value.BashArray, UP_val)
```

### Fixed: BUG set -x; arr+=(a b c) の出力が変

```
$ bin/osh -c 'a=(1 2 3); set -x; a+=(4 5 6)'
+ a+=( 1 2 3 4 5 6 )
```

追加された後の中身が、追加される要素のリストとして表示されている。これは変だ。

→これは修正した。


### Fixed: BUG set -x; a[10]=1; a+=(2) がクラッシュする

```
$ bin/osh -xc 'a[10]=1; a+=(4 5 6)'
+ a[10]=1
Traceback (most recent call last):
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 201, in <module>
    sys.exit(main(sys.argv))
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 170, in main
    return AppBundleMain(argv)
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 140, in AppBundleMain
    return shell.Main('osh', arg_r, environ, login_shell, loader, readline)
  File "/home/murase/.mwg/git/oilshell/oil/core/shell.py", line 1211, in Main
    cmd_flags=cmd_eval.IsMainProgram)
  File "/home/murase/.mwg/git/oilshell/oil/core/main_loop.py", line 375, in Batch
    is_return, is_fatal = cmd_ev.ExecuteAndCatch(node, cmd_flags)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 2103, in ExecuteAndCatch
    status = self._Execute(node)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1740, in _Dispatch
    status = self._ExecuteList(node.children)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1979, in _ExecuteList
    status = self._Execute(child)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1639, in _Dispatch
    status = self._DoShAssignment(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1006, in _DoShAssignment
    self.tracer.OnShAssignment(lval, pair.op, val, flags, which_scopes)
  File "/home/murase/.mwg/git/oilshell/oil/core/dev.py", line 726, in OnShAssignment
    _PrintShValue(val, buf)
  File "/home/murase/.mwg/git/oilshell/oil/core/dev.py", line 218, in _PrintShValue
    parts.append(j8_lite.MaybeShellEncode(s))
  File "/home/murase/.mwg/git/oilshell/oil/data_lang/j8_lite.py", line 38, in MaybeShellEncode
    if fastfunc.CanOmitQuotes(s):
TypeError: argument 1 must be string or read-only buffer, not None
```

これについては bash_impl に移動した後で ToStrForPrintBody (改名はする) を用意し
てそれを利用することにする。

然し sparse array の時に (); a[x]=y; ... という形にしなければならないとしたら色々
微妙。a=([10]=hello world test) 等にもし本当に対応するのだとしたら、其処を頑張っ
ても仕方がない。

→これも修正した。

### OK: for i: arr+=($i) が O(N^2) なのではないか?

現在の実装を見ているとそのような疑惑がある。

これは += の度に新しいインスタンスを作るのではなく extends を使って拡張する様に
変更したのでもう関係ない。

### Done: 既存の配列に対して再度属性を付加する時の動作?

```
builtin/assign_osh.py:468:                    if old_val.tag() != value_e.BashArray:
builtin/assign_osh.py:469:                        rval = value.BashArray([])
osh/cmd_eval.py:210:            elif tag == value_e.BashArray:
osh/cmd_eval.py:216:        elif case(value_e.BashArray):
osh/cmd_eval.py:220:            elif tag == value_e.BashArray:
osh/cmd_eval.py:221:                old_val = cast(value.BashArray, UP_old_val)
osh/cmd_eval.py:222:                to_append = cast(value.BashArray, UP_val)
osh/cmd_eval.py:228:                val = value.BashArray(strs)
```

+= による代入も一緒に処理する。

### Done: "declare -p sp"

```
builtin/assign_osh.py:163:        elif val.tag() == value_e.BashArray:
builtin/assign_osh.py:164:            array_val = cast(value.BashArray, val)
```

うーん。実装する上で色々と謎がある。

```
big1 = mops.IntWiden(1)
big2 = mops.IntWiden(2)
if big1 < big2:
    print("expected")
else:
    print("unexpected")
```

これを実行しようとすると `big1 < big2` の時点で

```
AssertionError: Use functions in mops.py
```

というエラーになる。

という事は一旦 i の配列を生成してそれを変換しなければならないのだろうか。或いは
Python sorted に lambda を指定すれば良いのだろう。

## declare, export, etc. の parsing がどうなっているのか分からない

オプションの解析と引数の読み取りが完全に別になっているがどういうことか。そもそ
も declare の引数は順番は気にしなくて良いのだったか?

と思ったが考えてみれば bash の場合はオプションの類は一番最初にまとめて指定しな
ければならないのだった。これについては osh も同様に処理している様だ。

```bash
$ bin/osh -c 'function hello { echo; }; function -world { echo; }; declare -f hello -world'
```

# 2024-12-07 以前

### Done: declare -p 判定部分

```
done: builtin/assign_osh.py:134:        if flag_a and val.tag() != value_e.BashArray:
done: builtin/assign_osh.py:148:            if val.tag() == value_e.BashArray:
```

これらの行はゆくゆくは完全に SparseArray に置き換えることになると思われる。そう
いう行については後でまとめて置換する? もしくはどちらも使える様にする?
現在のコードの実装だとどちらも使える様にしても良い様な気もする。

→うーん。BashArray を削除するのはしようと思えば簡単なので取り敢えずはどちらも
対応する方針で良い気がする。

下の様な記述ができるかどうか疑問だったがちゃんと mycpp で変換されている様だ。

```py
        if flag_a and val.tag() not in [value_e.BashArray, value_e.SparseArray]:
```

mycpp の変換はできるだけ逐語変換になる様にして複雑な物はライブラリ側でサポート
する様になっている? というかジェネレータ式などにも対応しているのだろうか。うー
ん。もう何も考えずに全て対応していると思って実装して、後で mycpp の側でちゃんと
変換されているか確かめるという方式の方が良い気がする。

### `unset -v a[last]` が正しく配列の長さを更新しない問題

うーん。これもバグだ。これは `unset` の前に修正する必要がある。

```
$ bin/osh -c 'a=(1); a[9]=x; unset -v "a[9]"; echo "${a[@]: -1}"'

$ bash -c 'a=(1); a[9]=x; unset -v "a[9]"; echo "${a[@]: -1}"'
1
```

https://github.com/oils-for-unix/oils/pull/2155

### OK: `ysh/val_opts`: ExactlyEqual で文字列の比較を != でしていて良いのか?

そもそも ExactlyEqual の機能を呼び出すにはどうすれば良いのか? 取り敢えず以下の
様にして `===` を使ってみるとちゃんと None と `!=` は区別されている様だ。実際に
`BashArray_Equals` が呼び出されているので OK のはず。

```bash
$ ysh -c 'shopt -s parse_sh_arith; declare -a a1=(1 "" 3) a2=(1 "" 3); unset "a2[1]"; echo $[a1 === a2]'
```

### BUG arr=(); arr[-10]=1 などとするとクラッシュするか変な事になるのでは

```bash
$ bash -c 'a=(1 2 3); a[-4]=x; declare -p a'
bash: line 1: a[-4]: bad array subscript
[ble: EXIT_FAILURE (1)]
$ bin/osh -c 'a=(1 2 3); a[-4]=x; declare -p a'
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 201, in <module>
    sys.exit(main(sys.argv))
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 170, in main
    return AppBundleMain(argv)
  File "/home/murase/.mwg/git/oilshell/oil/bin/oils_for_unix.py", line 140, in AppBundleMain
    return shell.Main('osh', arg_r, environ, login_shell, loader, readline)
  File "/home/murase/.mwg/git/oilshell/oil/core/shell.py", line 1211, in Main
    cmd_flags=cmd_eval.IsMainProgram)
  File "/home/murase/.mwg/git/oilshell/oil/core/main_loop.py", line 375, in Batch
    is_return, is_fatal = cmd_ev.ExecuteAndCatch(node, cmd_flags)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 2103, in ExecuteAndCatch
    status = self._Execute(node)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1740, in _Dispatch
    status = self._ExecuteList(node.children)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1979, in _ExecuteList
    status = self._Execute(child)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1647, in _Dispatch
    status = self._Execute(node.child)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1902, in _Execute
    status = self._Dispatch(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1639, in _Dispatch
    status = self._DoShAssignment(node, cmd_st)
  File "/home/murase/.mwg/git/oilshell/oil/osh/cmd_eval.py", line 1005, in _DoShAssignment
    self.mem.SetValue(lval, val, which_scopes, flags=flags)
  File "/home/murase/.mwg/git/oilshell/oil/core/state.py", line 1987, in SetValue
    strs[lval.index] = rval.s
IndexError: list assignment index out of range
[ble: EXIT_FAILURE (1)]
```
