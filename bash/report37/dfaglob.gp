#!/usr/bin/gnuplot

set encoding utf8
set terminal pdfcairo size 5,5/sqrt(2)
set output 'dfaglob.pdf'
time_offset = 0
#time_offset = 0.001090

lineZ = 'dt (12,4,4,4) lw 0.5'
label_newglob = 'strmatch\_ex'
label_regex = '<regex.h>'

#set format y '%.1t×10^{%T}'
set log y
set ylabel 'Time [ms]'
set yrange [1e-3:10000]
set title 'a. Benchmark: [[ xxx...xb == *(*(*(x))) ]]'
set log x
set xlabel 'Length of target string "xxx...xb"'
set key bottom right
plot \
  NaN w l lc rgb '#000000' dt (12,4) t 'Bash 5.2', \
  NaN w l lc rgb '#000000'           t label_newglob, \
  NaN w l lc rgb '#000000' dt (4,4)  t label_regex, \
  NaN w l lc rgb '#000000' @lineZ    t 'Zsh 5.8', \
  "< awk '$2 == 1' bash2.test1rex" u 1:($3/1000**2-time_offset) w l lc rgb '#0000FF' dt (4,4) notitle, \
  "< awk '$2 == 2' bash2.test1rex" u 1:($3/1000**2-time_offset) w l lc rgb '#00aa00' dt (4,4) notitle, \
  "< awk '$2 == 4' bash2.test1rex" u 1:($3/1000**2-time_offset) w l lc rgb '#888800' dt (4,4) notitle, \
  "< awk '$2 == 8' bash2.test1rex" u 1:($3/1000**2-time_offset) w l lc rgb '#FF0000' dt (4,4) notitle, \
  "< awk '$2 == 1' zsh.test1"      u ($1<=10000?$1:NaN):($3/1000**2-time_offset) w l lc rgb '#0000FF' @lineZ notitle, \
  "< awk '$2 == 2' zsh.test1"      u ($1<=10000?$1:NaN):($3/1000**2-time_offset) w l lc rgb '#00aa00' @lineZ notitle, \
  "< awk '$2 == 4' zsh.test1"      u ($1<=10000?$1:NaN):($3/1000**2-time_offset) w l lc rgb '#888800' @lineZ notitle, \
  "< awk '$2 == 8' zsh.test1"      u ($1<=10000?$1:NaN):($3/1000**2-time_offset) w l lc rgb '#FF0000' @lineZ notitle, \
  "< awk '$2 == 1' bash0.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#0000FF' dt (12,4) notitle, \
  "< awk '$2 == 1' bash2.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#0000FF'           t '*(x)', \
  "< awk '$2 == 2' bash0.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#00aa00' dt (12,4) notitle, \
  "< awk '$2 == 2' bash2.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#00aa00'           t '*(*(x))', \
  "< awk '$2 == 4' bash0.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#888800' dt (12,4) notitle, \
  "< awk '$2 == 4' bash2.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#888800'           t '*(*(*(*(x))))', \
  "< awk '$2 == 8' bash0.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#FF0000' dt (12,4) notitle, \
  "< awk '$2 == 8' bash2.test1" u 1:($3/1000**2-time_offset) w l lc rgb '#FF0000'           t '*(*(*(*(*(*(*(*(x))))))))'

set title 'b. Benchmark: a=xxx...x; a=$\{a%%+( )\}'
set xlabel 'Length of target string "xxx...x"'
plot \
  NaN w l lc rgb '#000000' dt (12,4) t 'Bash 5.2', \
  NaN w l lc rgb '#000000'           t label_newglob, \
  NaN w l lc rgb '#000000' @lineZ    t 'Zsh 5.8', \
  "< awk '$2 == 1' zsh.test2"   u 1:($3/1000**2-time_offset) w l lc rgb '#0000FF' @lineZ notitle, \
  "< awk '$2 == 2' zsh.test2"   u 1:($3/1000**2-time_offset) w l lc rgb '#00aa00' @lineZ notitle, \
  "< awk '$2 == 1' bash0.test2" u 1:($3/1000**2-time_offset) w l lc rgb '#0000FF' dt (12,4) notitle, \
  "< awk '$2 == 1' bash2.test2" u 1:($3/1000**2-time_offset) w l lc rgb '#0000FF'           t '$\{a%%+( )\}', \
  "< awk '$2 == 2' bash0.test2" u 1:($3/1000**2-time_offset) w l lc rgb '#00aa00' dt (12,4) notitle, \
  "< awk '$2 == 2' bash2.test2" u 1:($3/1000**2-time_offset) w l lc rgb '#00aa00'           t '$\{a##+( )\}'

set title 'c. Benchmark: a=$(yes | head -n 100); '."a=$\\{a//*( )$'\\\\n'*( )/$'\\\\n'\\}"
set xlabel 'Number of lines in the target string "y\ny\ny\n...\ny"'
plot \
  NaN w l lc rgb '#000000' dt (12,4) t 'Bash 5.2', \
  NaN w l lc rgb '#000000'           t label_newglob, \
  NaN w l lc rgb '#000000' @lineZ    t 'Zsh 5.8', \
  "< awk '$3 == 1' zsh.test3"   u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' @lineZ notitle, \
  "< awk '$3 == 2' zsh.test3"   u 1:($2/1000**2-time_offset) w l lc rgb '#00AA00' @lineZ notitle, \
  "< awk '$3 == 1' bash0.test3" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (12,4) notitle, \
  "< awk '$3 == 1' bash2.test3" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000'           t '$\{a//*( )'."$'\\\\n'".'*( )/'."$'\\\\n'".'\}', \
  "< awk '$3 == 2' bash0.test3" u 1:($2/1000**2-time_offset) w l lc rgb '#00AA00' dt (12,4) notitle, \
  "< awk '$3 == 2' bash2.test3" u 1:($2/1000**2-time_offset) w l lc rgb '#00AA00'           t '$\{a//+(['."$' \\\\t\\\\n'".'])/ \}'

set title 'd. Benchmark: a=$(printf '."'".'%0*d'."'".' 100000 0); [[ $a == +(0) ]]'
set xlabel 'Length of target string "000...0"'
plot \
  "bash0.test4"                    u 1:($2/1000**2-time_offset) w p lc rgb '#000000' t 'Bash 5.2', \
  "bash2.test4"                    u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' t label_newglob, \
  "< awk '$3 == 0' bash2.test6rex" u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' dt (4,4) t label_regex, \
  "zsh.test4"                      u ($1<=10000?$1:NaN):($2/1000**2-time_offset) w p lc rgb '#000088' lw 0.5 pt 2 t 'Zsh 5.8'

set title 'e. Benchmark: a=$(yes 3.14 | head -n 100); a=$\{a//+([0-9]).\}'
set xlabel 'Number of lines in the target string "3.14\n...\n3.14"'
plot \
  "bash0.test5" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (12,4) t 'Bash 5.2', \
  "bash2.test5" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000'           t label_newglob, \
  "zsh.test5"   u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' @lineZ    t 'Zsh 5.8'

set title 'f. Benchmark: a=$(printf '."'".'%0*d'."'".' 100000 0); [[ $a == +(!(x))y ]]'
set xlabel 'Length of target string "000...0"'
plot \
  NaN w l lc rgb '#000000' dt (12,4) t 'Bash 5.2', \
  NaN w l lc rgb '#000000'           t label_newglob, \
  NaN w l lc rgb '#000000' dt (4,4)  t label_regex, \
  NaN w l lc rgb '#000000' @lineZ    t 'Zsh 5.8', \
  "< awk '$3 == 1' bash2.test6rex" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (4,4)  notitle, \
  "< awk '$3 == 2' bash2.test6rex" u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' dt (4,4)  notitle, \
  "< awk '$3 == 1' zsh.test6"      u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' @lineZ    notitle, \
  "< awk '$3 == 2' zsh.test6"      u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' @lineZ    notitle, \
  "< awk '$3 == 1' bash0.test6"    u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (12,4) notitle, \
  "< awk '$3 == 1' bash2.test6"    u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000'           t '[[ $a == +(!(x))y ]]', \
  "< awk '$3 == 2' bash0.test6"    u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' dt (12,4) notitle, \
  "< awk '$3 == 2' bash2.test6"    u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF'           t '[[ $a == *(*)1 ]]'

# /(|[\^x]|...*)+y/
# /.**1/

set title 'g. Benchmark: a=$(printf '."'".'%0*d'."'".' 100000 0); [[ $a == hello ]]'
set xlabel 'Length of target string "000...0"'
plot \
  NaN w l lc rgb '#000000' dt (12,4) t 'Bash 5.2', \
  NaN w l lc rgb '#000000'           t label_newglob, \
  NaN w l lc rgb '#000000' dt (4,4)  t label_regex, \
  NaN w l lc rgb '#000000' @lineZ    t 'Zsh 5.8', \
  "< awk '$3 == \"1rex\"' bash2.test7" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (4,4)  notitle, \
  "< awk '$3 == \"2rex\"' bash2.test7" u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' dt (4,4)  notitle, \
  "< awk '$3 == 1' zsh.test7"          u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' @lineZ    notitle, \
  "< awk '$3 == 2' zsh.test7"          u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' @lineZ    notitle, \
  "< awk '$3 == 1' bash0.test7"        u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (12,4) notitle, \
  "< awk '$3 == 1' bash2.test7"        u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000'           t '[[ $a == hello ]]', \
  "< awk '$3 == 2' bash0.test7"        u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' dt (12,4) notitle, \
  "< awk '$3 == 2' bash2.test7"        u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF'           t '[[ $a == *a*b*c* ]]'

set title 'h. Benchmark: a=$(printf '."'".'%*s'."'".' 100000 ""); a=$\{a//" "\}'
set xlabel 'Length of target string "␣␣␣...␣"'
plot \
  NaN w l lc rgb '#000000' dt (12,4) t 'Bash 5.2', \
  NaN w l lc rgb '#000000'           t label_newglob, \
  NaN w l lc rgb '#000000' @lineZ    t 'Zsh 5.8', \
  "< awk '$3 == 1' zsh.test8"   u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' @lineZ    notitle, \
  "< awk '$3 == 2' zsh.test8"   u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' @lineZ    notitle, \
  "< awk '$3 == 1' bash0.test8" u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF' dt (12,4) notitle, \
  "< awk '$3 == 1' bash2.test8" u 1:($2/1000**2-time_offset) w l lc rgb '#0000FF'           t '$\{a//" "\}', \
  "< awk '$3 == 2' bash0.test8" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000' dt (12,4) notitle, \
  "< awk '$3 == 2' bash2.test8" u 1:($2/1000**2-time_offset) w l lc rgb '#FF0000'           t '$\{a//" "?(x)\}'
