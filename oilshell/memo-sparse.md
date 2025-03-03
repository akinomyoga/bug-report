
### Memo

PR を作るとそれに関連する push は CI でテストされる。テストの結果は以下に表示される

http://op.oilshell.org/uuu/github-jobs/

### asdl NewLeaf?

```
asdl/runtime.py:44:    # for repr of BashArray, which can have 'None'
```

これはよく分からないので後で確認する

この関数は `frontend/syntax_abbrev.py` から呼び出されていて、その他の場所からは
呼び出されていない様だ。つまり、構文木を構築する時点で呼び出される? だとすると
ここで BashArray が現れるのはよくわからない。或いは、昔は ShArrayLiteral を直接
BashArray にしていたという事?

変更を追跡すると 50a0720503 (2023-07-13) の前は MaybeStrArray だった様だ。

更に 10303458f6 で大きな書き換えがあって、その前は関数名は PrettyLeaf という名
前だった様だ。その時のコメントは、

```
if s is None:  # hack for repr of MaybeStrArray, which can have 'None'
```

になっていた。うーん。

更に遡ると e9089389e7 で StrArray から MaybeStrArray になっている。その前からこ
のコメントは存在した様だ。

そしてコメント及びコードは 441373c586 で追加されている。どうやらこれは repr と
いうコマンドで内容をダンプした時の表示方法を定義しているコード? そもそも
PrettyLeaf という名前から察するに pretty-print 用のコードだったという事だろうか。
一方で、現在もこの PrettyLeaf だか NewLeaf は実際に使われているのだろうか?
`frontend/syntax_abbrev.py` の最初の方に文法要素を pretty print するのに使って
いると書かれている。一方で、実際の使い方を見る限りは None が渡される事はないよ
うな気がする。長期の書き換えによって色々状況が変わったという事だろうか。何れに
しても今は InternalStringArray になっているが、この説明が正しいのかというとかな
り怪しく思われる。

うーん。repr を実行しようとしてみたが今はもう存在しない様だ。osh でも ysh でも
使えない。だとするとこの NewLeaf という関数はそもそも使われているのだろうか。
`frontend/syntax_abbrev.py` の中の関数は全く何処からも参照されていない気がする?
宣言があるだけで誰も使っていない。

つまり syntax_abbrev も含めて最早誰も使っていないコードという事だろうか。。。

### 'export builtin is disabled in YSH (shopt --set no_exported)'.

各 builtin の中でこの条件が判定されている。機能を提供するのは YSH の側なのだか
ら、YSH の側で対応している builtin のリストを管理するべきなのではないか。

### declare -f -- a=b が正しく処理できない

これは意図的な動作の可能性がある。或いは意識したことがなかったとしても、報告し
たとしても色々理由をつけて現状の動作の方が自然だの何だのという主張になる気がす
る。実際どちらが自然なのかというと微妙なので bash に合わせるのが本来自然の気が
するが。

```bash
$ bash -c 'function a=b() { echo hello; }; declare -f -- a=b'
function a=b ()
{
    echo hello
}
$ bin/osh -c 'function a=b() { echo hello; }; declare -f -- a=b'
  function a=b() { echo hello; }; declare -f -- a=b
                                  ^~~~~~~
[ -c flag ]:1: 'declare' with -f expects function names
[ble: usage_error (2)]
```

### declare -p a=b (invalid variable name) エラーが無視されている。

```bash
$ LANG=C.UTF-8 bash -c 'a=1; declare -p a=b'
bash: line 1: declare: a=b: not found
[ble: EXIT_FAILURE (1)]
$ bin/osh -c 'a=1; declare -p a=b'
[ble: EXIT_FAILURE (1)]
```

エラーメッセージも何も出力されないが実装を見てみると一旦は invalid を検出して
names に格納しているがその後に単に continue している。これは意図的な動作なのだ
ろうか?

### 関数一覧を declare -f で出力することができない

```bash
$ bash -c 'function fun1 { echo 1; }; declare -f'
fun1 ()
{
    echo 1
}
...
$ bin/osh -c 'function fun1 { echo 1; }; declare -f'
  function fun1 { echo 1; }; declare -f
                             ^~~~~~~
[ -c flag ]:1: 'declare' with -f expects function names
[ble: usage_error (2)]
```

### `BashArray(List[str?])` では?

```
core/value.asdl:105:  | BashArray(List[str] strs)
```

### `_SpaseArray_CanonicalizeIndex` 等の名前は C++ 的には UB ではないか

既に沢山使われれているので今更である。対策するとしたら C++ に出力する時に識別子
を一括で変換する。特に _ で始まるものは internal を前につけるなど。何れにしても
これは必要になるまではしないという決断がくだされる気がするが。

うーん。各モジュールの名前空間の中で使っているから OK? と思ったが、
_[A-Z]... は C の予約識別子でマクロに使われる可能性もあるから、やはり UB である。

### word_eval: BashAssoc-slice

そもそも BashAssoc に対して slice が実装されていない。

```
osh/word_eval.py:411:            result = value.BashArray(strs)
osh/word_eval.py:574:            val = value.BashArray(argv)  # type: value_t
```
### `ysh/val_opts`: ExactlyEqual の実装に関しては参照で最適化できるのではないか?

つまりそもそも両辺が同じオブジェクトを指しているのであれば中身を見る必要はないのである。

### 現状の BashArray の実装だと BigInt index に対応していない

BashArray を呼び出している諸々の場所でも BigInt index に対応していない。つまり、
SparseArray を単純に置き換えたとしても SparseArray に対して BigInt index を使う
インターフェイスが今のところないという事になる。

2025-03-03 これは現在色々いい感じになっているはずだがちゃんと確認した訳ではない
ので改めて全て確認する必要がある? 特に SetElement と GetElement の呼び出し元を
確認する。算術式のアクセスの時にちゃんと BigInt になっているか確認する。

### nameref

```console
$ bash -c 'declare -n ref="a[@]"; a=(1 2 3); printf "<%s>\\n" "$ref"'
<1>
<2>
<3>
$ bash -c 'declare -n ref="a[0]"; a=(1 2 3); printf "<%s>\\n" "$ref"'
<1>
$ bash -c 'declare -n ref="a"; a=(1 2 3); printf "<%s>\\n" "$ref"'
<1>
$ bin/osh -c 'declare -n ref="a[@]"; a=(1 2 3); printf "<%s>\\n" "$ref"'
<a[@]>
$ bin/osh -c 'declare -n ref="a[0]"; a=(1 2 3); printf "<%s>\\n" "$ref"'
<a[0]>
$ bin/osh -c 'declare -n ref="a"; a=(1 2 3); printf "<%s>\\n" "$ref"'
<1>
```

```
$ bash -c 'a=(1 2 3); printf "<%s>\\n" "${a[@]@a}"'
<a>
<a>
<a>
$ bin/osh -c 'a=(1 2 3); printf "<%s>\\n" "${a[@]@a}"'
<a>
```

## master の上に居ると yapf-changed が全く実行されない

もしかして変更したファイルの検出を既に commit されている物を使って行っている?
