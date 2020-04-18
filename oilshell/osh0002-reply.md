
> But it is even more complicated than local scope and dynamic scope,
> because you also have these "temp bindings" to worry about.
> https://github.com/oilshell/oil/issues/653#issuecomment-613774521 by
> @andychu

I'm sorry, it took much time to investigate the behavior of these temporary bindings (`tempenv`).
I have never tested the interaction of `unset` and `tempenv`, so
I was investigating it with Bash and puzzled by its strange behavior.
I think now I came to a conclusion. Here I summarize my investigation.

## 1. Bug in Bash-4.3..5.0 and tempenv/local/unset

I was searching inside the Bash source code (where I found that these temporary bindings are called `tempenv` in the Bash source code).
Finally it turned out that actually there is a bug in Bash-4.3..5.0, which was now fixed in the devel branch of Bash.
Also, the treatment of `tempenv` has been largely changed from Bash 4.3, so **we need to test with the devel branch of Bash to know its behavior**.

<details><summary>Details of Bug</summary>

```bash
#!/bin/bash

# bash 4.3..5.0 bug

f1() {
  local v=local
  unset -v v # this is local-scope unset
  echo "$v"
}

v=global
v=tempenv f1

# Results:
#   Bash 2.05b-4.2    outputs "v: (unset)"
#   Bash 4.3-5.0      outputs "v: global"
#   Bash devel branch outputs "v: (unset)"
```

The fix was made just about two months ago in the commit f65f3d54 (commit bash-20200207 snapshot).
This is the related ChangeLog:

> ```
>             2/6
>             ---
> variables.c
>   - make_local_variable: make sure local variables that have the same
>     names as variables found in the temporary environment are marked as
>     local. From Grisha Levit <address@hidden> back in 12/2018
> ```

This bug was actually reported one year and half ago.

https://lists.gnu.org/archive/html/bug-bash/2018-12/msg00031.html

> From: Grisha Levit
>
> Subject:  should 'local' create local variables when they exist in the tempenv?
>
> Date: Sun, 9 Dec 2018 01:30:53 -0500
>
> When a variable is present in the temporary environment and then
> declared local in a function, it seems to not actually make a local
> variable, in the sense that the variable does not show up in the
> output of `local', unsetting the variable reveals the variable from
> the higher scope rather than marking it invisible, etc.
>
> ```bash
> $ f() { local v=x; local -p; }; v=t f
> 
> $ f() { local v; declare -p v; }; v=t f
> declare -x v="t"
> 
> $ f() { local v=x; unset v; declare -p v; }; v=g; v=t f
> declare -- v="g"
> ```
>
> Is this intentional?

</details>


## 2. Interaction of tempenv/localvar/eval/unset

Here I summarize the behavior in Bash 4.3+.
The treatment of tempenv has been largely changed in Bash 4.3.
And there was an additional fix in the devel branch which will be released in Bash 5.1.
I haven't checked the actual implementation in detail,
but the observable behavior can be explained by the following model.

The function has its own variable context (let us call it `local_context`).
In addition, we can create multilevel nested variable contexts in a function scope by `v=xxx eval '...'`.
There are two types of the variable defined in any of the function-scope contexts: `tempenv` and `localvar`.
Each variable has a flag to indicate if it is a `tempenv` or `localvar`.

### Function call with `tempenv`
The function call of the form `v=xxx fn` creates a `tempenv` in `local_context` of `fn`.

### Builtin `local`

When one attepts to create a variable by `local` builtin,
Bash first searches an existing variable cell with the same name.
- If `localvar` or `tempenv` is found in the current function, it reuses the cell.
  When it is `tempenv`, Bash removes the `tempenv` flag to turn it into `localvar`.
  When a value is specified for `local`, the existing value is overwritten by the specified value.
- Otherwise, Bash creates a new `localvar` in `local_context` of the
  current function.  If a value is specified for `local`, the variable
  is initialized with the specified value.  Otherwise, if `shopt -s
  localvar_inherit` is set or there is an existing `tempenv`, the
  value is inherited from the existing variable.  Otherwise, the value
  is `Undef`.

The behavior is complicated, so I don't think Oil should exactly
follow Bash behavior particularly for the case where `eval` (nested
contexts in a function) is involved (until we find any Bash script
that uses such a structure like `v=xxx eval 'unset v` or `v=xxx eval
'local v`.  `ble.sh` doesn't use such a structure).

### Builtin `unset`

`unset` can have two different behaviors: local-scope unset
(`value-unset`) and dynamic unset (`cell-unset`).  If `shopt -s
localvar_unset` is set or the target variable is `localvar` in the
current function, `unset` performs `value-unset`.  Otherwise, `unset`
is always `cell-unset`.

To implement it in Oil, you can forget about the option `shopt -s
localvar_unset`. Then, the rule is simple: **If the variable is
`localvar` of the current function scope, `value-unset` is
prformed. Otherwise, `cell-unset` is performed.**

<details><summary>Test cases</summary>

Here are test cases to demonstrate the above behavior.
Results are obtained by the devel branch of Bash. I will create PR for spec tests later.

### 1. local-scope/dynamic unset (local)

```bash
#!/bin/bash

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
```

Result
```
[global,local,(unset)] v: (unset)
[global,local,(unlocal)] v: global
```

### 2. local-scope/dynamic unset (tempenv&local)

`local` mutates `tempenv` to `localvar` rather than shadows it.

```bash
#!/bin/bash

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
```

Result
```
[global,tempenv,local,(unset)] v: (unset)
[global,tempenv,local,(unlocal)] v: global
```

### 3. local-scope/dynamic unset (tempenv)

`unset` for `tempenv` is always dynamic `unset`.

```bash
#!/bin/bash

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
```

Result
```
[global,tempenv,(unset)] v: global
[global,tempenv,(unlocal)] v: global
```

### 4. tempvar through eval

While `v=xxx fn` creates `tempenv` in `local_context` of `fn`,
`v=xxx eval fn` creates `tempenv` outside of the function `fn`.

```bash
#!/bin/bash

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
```

Result
```
[global] v: global
[global,local] v: (unset)
[global,local+unset] v: (unset)
[global,local+unlocal] v: global
[global,tempenv] v: tempenv
[global,tempenv,local] v: tempenv
[global,tempenv,local+unset] v: (unset)
[global,tempenv,local+unlocal] v: global
[global,tempenv,(eval)] v: tempenv
[global,tempenv,(eval),local] v: tempenv
[global,tempenv,(eval),local+unset] v: (unset)
[global,tempenv,(eval),local+unlocal] v: tempenv
```

### 5. local inherits the value of tempenv

It doesn't inherit the value of normal exported variables.
It only inherits the value of `tempenv`.


```bash
#!/bin/bash

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
```

Result
```
[global,tempenv,(func),(local)] v: tempenv
[xglobal,(func),(local)] v: (unset)
```


### 6. `v=xxx eval ''`

`v=xxx eval '...'` can create a nested variable context in a function.
`local` mutates `tempenv` to `localvar`.

```bash
#!/bin/bash

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
```

Result
```
[global,tempenv1,local1] v: local1
[global,tempenv1,local1,tempenv2,(eval)] v: tempenv2
[global,tempenv1,local1,tempenv2,(eval),local2] v: local2
[global,tempenv1,local1] v: local1 (after)
```

### 7. local-scope/dynamic unset (nested context localvar)


```bash
#!/bin/bash

unlocal() { unset -v "$1"; }

f2() {
  local v=local1
  v=tempenv2 eval '
    local v=local2
    (unset v  ; echo "[$1,local1,tempenv2,(eval),local2,(unset)] v: ${v-(unset)}")
    (unlocal v; echo "[$1,local1,tempenv2,(eval),local2,(unlocal)] v: ${v-(unset)}")
  '
}
v=tempenv1 f2 global,tempenv1
```

Result
```
[global,tempenv1,local1,tempenv2,(eval),local2,(unset)] v: (unset)
[global,tempenv1,local1,tempenv2,(eval),local2,(unlocal)] v: local1
```

### 8. dynamic unset (nested context localvar x3)


```bash
#!/bin/bash

unlocal() { unset -v "$1"; }

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
```

Result
```
[global,tempenv1/local1,tempenv2/local2,tempenv3/local3] v: local3
[global,tempenv1/local1,tempenv2/local2,tempenv3/local3] v: local2 (unlocal 1)
[global,tempenv1/local1,tempenv2/local2,tempenv3/local3] v: local1 (unlocal 2)
[global,tempenv1/local1,tempenv2/local2,tempenv3/local3] v: global (unlocal 3)
[global,tempenv1/local1,tempenv2/local2,tempenv3/local3] v: (unset) (unlocal 4)
```

### 9. dynamic unset by unlocal (nested context tempenv x3)

`unset` removes the cell for each nested context one by one.

```bash
#!/bin/bash

unlocal() { unset -v "$1"; }

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
```

Result
```
[global,tempenv1,tempenv2,tempenv3] v: tempenv3
[global,tempenv1,tempenv2,tempenv3] v: tempenv2 (unlocal 1)
[global,tempenv1,tempenv2,tempenv3] v: tempenv1 (unlocal 2)
[global,tempenv1,tempenv2,tempenv3] v: global (unlocal 3)
[global,tempenv1,tempenv2,tempenv3] v: (unset) (unlocal 4)
```

### 10. dynamic unset by unset (nested context tempenv x3)

`unset` for `tempenv` in the current function is also dynamic `unset`.


```bash
#!/bin/bash

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

```

Result
```
[global,tempenv1,tempenv2,tempenv3] v: tempenv3
[global,tempenv1,tempenv2,tempenv3] v: tempenv2 (unset 1)
[global,tempenv1,tempenv2,tempenv3] v: tempenv1 (unset 2)
[global,tempenv1,tempenv2,tempenv3] v: global (unset 3)
[global,tempenv1,tempenv2,tempenv3] v: (unset) (unset 4)
```

</details>

## 3. `shopt -s localvar_unset`

> Is the bash 5.0 behavior with localvar_unset OK? I would rather keep
> it simple rather than have too many special cases, but still
> compatible. It's hard to write documentation when there are too many
> special cases.
> https://github.com/oilshell/oil/issues/653#issuecomment-613774521 by
> @andychu

No. Actually you can just forget about `localvar_unset`.  Existing
many Bash programs including `bash-completion` doesn't work with
`shopt -s localvar_unset`.  And, no *Bash* program uses `shopt -s
localvar_unset`.  I just tested with that option for completeness.

There is a story for `localvar_unset`. About two years ago, a man
appeared in bug-bash mailing list and insisted that the dynamic unset
behavior is *bug* and try to change the existing behavior of Bash.
Chet and other people try to convince him that the behavior is
intensional one even if it is tricky or quirky, there are many
existing scripts relying on that behavior, the behavior varies among
shells so there is no established *correct behavior*.  But we could
not convince him, and he continued to post replies to the mailing list
for a long time.  Finally Chet implemented an option `localvar_unset`
for him, but I don't think he has actually written a script affected
by that option because the original discussion is started by the
question from another user but not by him.

I have searched [the use of `localvar_unset` in GitHub](https://github.com/search?q=%22localvar_unset%22+language%3AShell&type=Code).
We can find only two programs that use `localvar_unset`, `ble.sh` and `modernish`.
A few other scripts just enumerates all the `shopt` options.
- `ble.sh` temporarilly turn off `localvar_unset` to implement dynamic
  `unset` when `localvar_unset` is enabled.
- `modernish` turns on `localvar_unset` to make a behavior more common
  to other shells.  As you know `modernish` tries to make a universal
  shell scripting experience which can run on a wide range of POSIX
  shells.  In this sense, `modernish` is not compatible with real Bash
  scripts like `bash-completion` and others which are full of Bashism.

----

> Does the behavior as of the last commit make it work?
> https://github.com/oilshell/oil/issues/653#issuecomment-613774521 by
> @andychu


To implement the Bash behavior, we need to switch between these two
behavior depending on a situation. The conlusion of the above
discussion is: **If the variable is `localvar` of the current function
scope, `value-unset` is prformed. Otherwise, `cell-unset` is
performed.**

> This statement and the table below doesn't exactly match what I
> observe... maybe you can add some test cases below #24 in
> `spec/builtin-vars.test.sh`?
> https://github.com/oilshell/oil/issues/653#issuecomment-613774521 by
> @andychu

> I will look at it more later but having a test case for exactly
> what's used in ble.sh will help.
> https://github.com/oilshell/oil/issues/653#issuecomment-613774521 by
> @andychu

> Since people rely on the bash idiom, it's probably better to change
> it to be closer to that, but I'm not sure exactly how. So yeah
> having the exact test cases for ble.sh will help, e.g. in
> `spec/ble-idioms.tset.sh`. by @andychu
> https://github.com/oilshell/oil/issues/653#issuecomment-613775611 by
> @andychu

> That is hysterical. I can't see from the test results... what's your
> test case for temp bindings and/or locals and unset?
> https://github.com/oilshell/oil/issues/706#issuecomment-614982326 by
> @mgree

> I think we have to come up with some better test cases ...
> https://github.com/oilshell/oil/issues/706#issuecomment-614987077
> by @andychu

I'm sorry for the late reply.  Later, I will try to add test cases in
`spec/{builtin-vars,ble-idioms}.test.sh`.  I haven't tested so much
with other shells, but it seems the model is completely different
between any shells.

> Also, if it helps, we could upgrade the version in test/spec-bin.sh
> to bash 5.0 rather than 4.4
> https://github.com/oilshell/oil/issues/706#issuecomment-613778933
> by @andychu

Although Bash 5.0 has an option `shopt -s localvar_unset`, effectively
no Bash program uses that option.  Also, as the local/unset bug of
Bash 4.3 is not yet fixed in Bash 5.0, I think we don't have to
upgrade it.
