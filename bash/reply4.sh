

f1() {
  local b=1
  ! local -p a &>/dev/null; echo $?
  ! local -p b &>/dev/null; echo $?
}
f2() {
  local a=1
  f1
}
f2

#------------------------------------------------------------------------------

# In older versions
function ble/variable#is-global/.test { ! local "$1" 2>/dev/null; }
function ble/variable#is-global {
  (readonly "$1"; ble/variable#is-global/.test "$1")
}

is-global() {
 [[ ${1+set} ]] && (readonly "$1"; ! local "$1")
} &>/dev/null

a=1
f1() {
  local b=1
  is-global a; echo "a $?"
  is-global b; echo "b $?"
  is-global c; echo "c $?"
}
f1

#------------------------------------------------------------------------------
echo UsingUnset
shopt -u localvar_inherit 2>/dev/null

a=1
f1() {
  local c=1
  # a=1 eval 'local a; [[ ${a+set} ]]'; echo "$? (1)"
  # b=1 eval 'local b; [[ ${b+set} ]]'; echo "$? (1)"
  # c=1 eval 'local c; [[ ${c+set} ]]'; echo "$? (0)"
  (a=1;local a;[[ ${a+set} ]]); echo "$? (1)"
  (b=1;local b;[[ ${b+set} ]]); echo "$? (1)"
  (c=1;local c;[[ ${c+set} ]]); echo "$? (0)"
}
f2() {
  local b=1
  f1
}
f2
