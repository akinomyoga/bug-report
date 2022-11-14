#!/usr/bin/gnuplot

set encoding utf8
set terminal pdfcairo size 5,5/sqrt(2)
set output 'dfaglob.pdf'
time_offset = 0
#time_offset = 0.001090

using1 = 'u 1:($2/1000**2-time_offset)'
using2 = 'u ($1<=1e4?$1:NaN):($2/1000**2-time_offset)' # limit the range for zsh crash
lineN = 'w l'
lineB = 'w l dt (12,4)'
lineR = 'w l dt (4,4)'
lineZ = 'w l dt (16,3,4,3) lw 0.5'
lineK = 'w l dt (12,2,2,2,2,2) lw 0.5'
label_newglob = 'strmatch\_ex'
label_regex = '<regex.h>'
zsh = 'zsh'


#set format y '%.1t×10^{%T}'
set log y
set ylabel 'Time [ms]'
set yrange [1e-3:10000]
set title 'a. Benchmark: [[ xxx...xb == *(*(*(x))) ]]'
set log x
set xlabel 'Length of target string "xxx...xb"'
set key bottom right
plot \
  NaN @lineB lc rgb '#000000' t 'Bash 5.2', \
  NaN @lineN lc rgb '#000000' t label_newglob, \
  NaN @lineR lc rgb '#000000' t label_regex, \
  NaN @lineZ lc rgb '#000000' t 'Zsh 5.8', \
  "< awk '$3 == 1' bash2.test1rex" @using1 @lineR lc rgb '#0000FF' notitle, \
  "< awk '$3 == 2' bash2.test1rex" @using1 @lineR lc rgb '#00aa00' notitle, \
  "< awk '$3 == 4' bash2.test1rex" @using1 @lineR lc rgb '#888800' notitle, \
  "< awk '$3 == 8' bash2.test1rex" @using1 @lineR lc rgb '#FF0000' notitle, \
  "< awk '$3 == 1' ".zsh.".test1"  @using2 @lineZ lc rgb '#0000FF' notitle, \
  "< awk '$3 == 2' ".zsh.".test1"  @using2 @lineZ lc rgb '#00aa00' notitle, \
  "< awk '$3 == 4' ".zsh.".test1"  @using2 @lineZ lc rgb '#888800' notitle, \
  "< awk '$3 == 8' ".zsh.".test1"  @using2 @lineZ lc rgb '#FF0000' notitle, \
  "< awk '$3 == 1' bash0.test1"    @using1 @lineB lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' bash2.test1"    @using1 @lineN lc rgb '#0000FF' t '*(x)', \
  "< awk '$3 == 2' bash0.test1"    @using1 @lineB lc rgb '#00aa00' notitle, \
  "< awk '$3 == 2' bash2.test1"    @using1 @lineN lc rgb '#00aa00' t '*(*(x))', \
  "< awk '$3 == 4' bash0.test1"    @using1 @lineB lc rgb '#888800' notitle, \
  "< awk '$3 == 4' bash2.test1"    @using1 @lineN lc rgb '#888800' t '*(*(*(*(x))))', \
  "< awk '$3 == 8' bash0.test1"    @using1 @lineB lc rgb '#FF0000' notitle, \
  "< awk '$3 == 8' bash2.test1"    @using1 @lineN lc rgb '#FF0000' t '*(*(*(*(*(*(*(*(x))))))))'

set title 'b. Benchmark: a=xxx...x; a=$\{a%%+( )\}'
set xlabel 'Length of target string "xxx...x"'
plot \
  NaN @lineB lc rgb '#000000' t 'Bash 5.2', \
  NaN @lineN lc rgb '#000000' t label_newglob, \
  NaN @lineZ lc rgb '#000000' t 'Zsh 5.8', \
  "< awk '$3 == 1' ".zsh.".test2" @using1 @lineZ lc rgb '#0000FF' notitle, \
  "< awk '$3 == 2' ".zsh.".test2" @using1 @lineZ lc rgb '#00aa00' notitle, \
  "< awk '$3 == 1' bash0.test2"   @using1 @lineB lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' bash2.test2"   @using1 @lineN lc rgb '#0000FF' t '$\{a%%+( )\}', \
  "< awk '$3 == 2' bash0.test2"   @using1 @lineB lc rgb '#00aa00' notitle, \
  "< awk '$3 == 2' bash2.test2"   @using1 @lineN lc rgb '#00aa00' t '$\{a##+( )\}'

set title 'c. Benchmark: a=$(yes | head -n 100); '."a=$\\{a//*( )$'\\\\n'*( )/$'\\\\n'\\}"
set xlabel 'Number of lines in the target string "y\ny\ny\n...\ny"'
plot \
  NaN @lineB lc rgb '#000000' t 'Bash 5.2', \
  NaN @lineN lc rgb '#000000' t label_newglob, \
  NaN @lineZ lc rgb '#000000' t 'Zsh 5.8', \
  "< awk '$3 == 1' ".zsh.".test3" @using1 @lineZ lc rgb '#FF0000' notitle, \
  "< awk '$3 == 2' ".zsh.".test3" @using1 @lineZ lc rgb '#00AA00' notitle, \
  "< awk '$3 == 1' bash0.test3"   @using1 @lineB lc rgb '#FF0000' notitle, \
  "< awk '$3 == 1' bash2.test3"   @using1 @lineN lc rgb '#FF0000' t '$\{a//*( )'."$'\\\\n'".'*( )/'."$'\\\\n'".'\}', \
  "< awk '$3 == 2' bash0.test3"   @using1 @lineB lc rgb '#00AA00' notitle, \
  "< awk '$3 == 2' bash2.test3"   @using1 @lineN lc rgb '#00AA00' t '$\{a//+(['."$' \\\\t\\\\n'".'])/ \}'

set title 'd. Benchmark: a=$(printf '."'".'%0*d'."'".' 100000 0); [[ $a == +(0) ]]'
set xlabel 'Length of target string "000...0"'
plot \
  "bash0.test4"                    @using1 w p    lc rgb '#000000' t 'Bash 5.2', \
  "bash2.test4"                    @using1 @lineN lc rgb '#0000FF' t label_newglob, \
  "< awk '$3 == 0' bash2.test6rex" @using1 @lineR lc rgb '#0000FF' t label_regex, \
  "".zsh.".test4"                  @using2 w p lc rgb '#000088' lw 0.5 pt 2 t 'Zsh 5.8'

set title 'e. Benchmark: a=$(yes 3.14 | head -n 100); a=$\{a//+([0-9]).\}'
set xlabel 'Number of lines in the target string "3.14\n...\n3.14"'
plot \
  "bash0.test5"   @using1 @lineB lc rgb '#FF0000' t 'Bash 5.2', \
  "bash2.test5"   @using1 @lineN lc rgb '#FF0000' t label_newglob, \
  "".zsh.".test5" @using1 @lineZ lc rgb '#FF0000'    t 'Zsh 5.8'

set title 'f. Benchmark: a=$(printf '."'".'%0*d'."'".' 100000 0); [[ $a == +(!(x))y ]]'
set xlabel 'Length of target string "000...0"'
plot \
  NaN @lineB lc rgb '#000000' t 'Bash 5.2', \
  NaN @lineN lc rgb '#000000' t label_newglob, \
  NaN @lineR lc rgb '#000000' t label_regex, \
  NaN @lineZ lc rgb '#000000' t 'Zsh 5.8', \
  "< awk '$3 == 1' bash2.test6rex" @using1 @lineR lc rgb '#FF0000' notitle, \
  "< awk '$3 == 2' bash2.test6rex" @using1 @lineR lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' zsh.test6"      @using1 @lineZ lc rgb '#FF0000' notitle, \
  "< awk '$3 == 2' ".zsh.".test6"  @using1 @lineZ lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' bash0.test6"    @using1 @lineB lc rgb '#FF0000' notitle, \
  "< awk '$3 == 1' bash2.test6"    @using1 @lineN lc rgb '#FF0000' t '[[ $a == +(!(x))y ]]', \
  "< awk '$3 == 2' bash0.test6"    @using1 @lineB lc rgb '#0000FF' notitle, \
  "< awk '$3 == 2' bash2.test6"    @using1 @lineN lc rgb '#0000FF' t '[[ $a == *(*)1 ]]'

# /(|[\^x]|...*)+y/
# /.**1/

set title 'g. Benchmark: a=$(printf '."'".'%0*d'."'".' 100000 0); [[ $a == hello ]]'
set xlabel 'Length of target string "000...0"'
plot \
  NaN @lineB lc rgb '#000000' t 'Bash 5.2', \
  NaN @lineN lc rgb '#000000' t label_newglob, \
  NaN @lineR lc rgb '#000000' t label_regex, \
  NaN @lineZ lc rgb '#000000' t 'Zsh 5.8', \
  "< awk '$3 == \"1rex\"' bash2.test7" @using1 @lineR lc rgb '#FF0000' notitle, \
  "< awk '$3 == \"2rex\"' bash2.test7" @using1 @lineR lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' ".zsh.".test7"      @using1 @lineZ lc rgb '#FF0000' notitle, \
  "< awk '$3 == 2' ".zsh.".test7"      @using1 @lineZ lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' bash0.test7"        @using1 @lineB lc rgb '#FF0000' notitle, \
  "< awk '$3 == 1' bash2.test7"        @using1 @lineN lc rgb '#FF0000' t '[[ $a == hello ]]', \
  "< awk '$3 == 2' bash0.test7"        @using1 @lineB lc rgb '#0000FF' notitle, \
  "< awk '$3 == 2' bash2.test7"        @using1 @lineN lc rgb '#0000FF' t '[[ $a == *a*b*c* ]]'

set title 'h. Benchmark: a=$(printf '."'".'%*s'."'".' 100000 ""); a=$\{a//" "\}'
set xlabel 'Length of target string "␣␣␣...␣"'
plot \
  NaN @lineB lc rgb '#000000' t 'Bash 5.2', \
  NaN @lineN lc rgb '#000000' t label_newglob, \
  NaN @lineZ lc rgb '#000000' t 'Zsh 5.8', \
  "< awk '$3 == 1' ".zsh.".test8" @using1 @lineZ lc rgb '#0000FF' notitle, \
  "< awk '$3 == 2' ".zsh.".test8" @using1 @lineZ lc rgb '#FF0000' notitle, \
  "< awk '$3 == 1' bash0.test8"   @using1 @lineB lc rgb '#0000FF' notitle, \
  "< awk '$3 == 1' bash2.test8"   @using1 @lineN lc rgb '#0000FF' t '$\{a//" "\}', \
  "< awk '$3 == 2' bash0.test8"   @using1 @lineB lc rgb '#FF0000' notitle, \
  "< awk '$3 == 2' bash2.test8"   @using1 @lineN lc rgb '#FF0000' t '$\{a//" "?(x)\}'
