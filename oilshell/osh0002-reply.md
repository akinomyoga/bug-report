
> But it is even more complicated than local scope and dynamic scope, because you also have these "temp bindings" to worry about.

I'm sorry, it took much time to investigate the behavior of these temporary bindings (`tempenv`).
I have never tested the interaction of `unset` and `tempenv`, so
I was investigating it with Bash and puzzled by its strange behavior.
I think now I came to a conclusion. Here I summarize my investigation.

## 1. tempenv and unset bug in Bash-4.3..5.0

I was searching inside the Bash source code (where I found that these temporary bindings are called `tempenv` in the Bash source code).
Finally it turned out that actually there is a bug in Bash-4.3..5.0, which was now fixed in the devel branch of Bash.

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


## 2. The interaction of tempenv/localvar/eval/unset

Here I summarize the behavior in Bash 4.3+.
The treatment of tempenv has been largely changed in Bash 4.3.
And there was an additional fix in the devel branch which will be released in Bash 5.1.
I haven't checked the actual implementation in detail,
but the observable behavior can be explained by the following model.

The function has its own variable context (let us call it `local_context`).
In addition, we can create multilevel nested variable contexts in a function scope by `v=xxx eval '...'`.
There are two types of the variable defined in any of the function-scope contexts: `tempenv` and `localvar`.
Each variable has a flag to indicate if it is a `tempenv` or `localvar`.

The function call of the form `v=xxx fn` creates a `tempenv` in `local_context` of `fn`.

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

`unset` can have two different behaviors: local-scope unset
(`value-unset`) and dynamic unset (`cell-unset`).  If `shopt -s
localvar_unset` is set or the target variable is `localvar` in the
current function, `unset` performs `value-unset`.  Otherwise, `unset`
is always `cell-unset`.


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

```
# result
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

```
# result
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

```
# result
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

```
# result
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

```
# result
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

```
# result
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

```
# result
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

```
# result
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

```
# result
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

```
# result
[global,tempenv1,tempenv2,tempenv3] v: tempenv3
[global,tempenv1,tempenv2,tempenv3] v: tempenv2 (unset 1)
[global,tempenv1,tempenv2,tempenv3] v: tempenv1 (unset 2)
[global,tempenv1,tempenv2,tempenv3] v: global (unset 3)
[global,tempenv1,tempenv2,tempenv3] v: (unset) (unset 4)
```
