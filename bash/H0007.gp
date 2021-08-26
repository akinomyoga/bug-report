#!/usr/bin/gnuplot

set encoding utf8
set minussign
set terminal pdfcairo size 3.5,3.5 font 'Times,'
set output 'H0007-complexity.pdf'
wline1 = "w line lc rgb '#FF0000'"
wline2 = "w line lc rgb '#00aa00' dt (16,4)"
wline3 = "w line lc rgb '#0000FF' dt (12,4,4,4)"
wline4 = "w line lc rgb '#DD6600' dt (3,3) lw 2"
wline5 = "w line lc rgb '#880088' dt (12,4,4,4,4,4)"
wline6 = "w line lc rgb '#0088DD' dt (8,4)"
set key top left
set log x
set log y
set ylabel 'Time [μs]'
set xlabel '# of characters'
plot \
  '< grep "\bf1\b" H0007-complexity.txt'   u 1:($3/1000) @wline1 title 'f1', \
  '< grep "\bf2\b" H0007-complexity.txt'   u 1:($3/1000) @wline2 title 'f2', \
  '< grep "\bf7\b" H0007-complexity.txt'   u 1:($3/1000) @wline3 title 'f7', \
  '< grep "\bf8\b" H0007-complexity.txt'   u 1:($3/1000) @wline4 title 'f8', \
  '< grep "\bf12\b" H0007-complexity.txt'  u 1:($3/1000) @wline5 title 'f12', \
  '< grep "\bf21b\b" H0007-complexity.txt' u 1:($3/1000) @wline6 title 'f21b'
