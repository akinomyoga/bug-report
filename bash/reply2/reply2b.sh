a=1
f1() { local -n b=a; local a=$b; declare -p a; }
f2() { local -n b=a; local -a a=("$b"); declare -p a; }
f1
f2
