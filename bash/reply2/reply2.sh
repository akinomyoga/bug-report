a=1
f1() { local a=$a; local; }
f2() { local -a a=("$a"); local; }
f1
f2
