#!/usr/bin/gnuplot

# set terminal pngcairo size 800,600
# set output 'rss-vs-commit.png'
set terminal pdfcairo size 3.5,3.5/sqrt(2.0)
set output 'rss-vs-commit.pdf'
set xlabel '#commit'
set ylabel 'ΔRSS (MB)'
set key bottom right

set label 1 at first 315,16.2 offset -0.8,0 rotate by 45 font ',7' front 'a314357'
set label 2 at first 320,16.2 offset  0.1,0 rotate by 45 font ',7' front '1665e22'
set label 3 at first 362,16.2 offset -0.3,0 rotate by 45 font ',7' front '9fc7642'
set label 4 at first 392,16.2 offset -0.3,0 rotate by 45 font ',7' front '987daba'
set label 5 at first 403,16.2 offset -0.3,0 rotate by 45 font ',7' front 'b13b8a8'
set label 6 at first 411,16.2 offset  0.0,0 rotate by 45 font ',7' front '4b82d1c'
set label 7 at first 412,16.2 offset  1.1,0 rotate by 45 font ',7' front 'e67d002'
set label 8 at first 413,16.2 offset  2.2,0 rotate by 45 font ',7' front 'e3db237 (+ expr.c fix)'
set label 9 at first 414,16.2 offset  3.3,0 rotate by 45 font ',7' front '2dead0c (+ expr.c fix)'

set label 10 at first 415,26.2 offset -1.2,0 rotate by 45 font ',7' front 'ba4ab05'
set label 11 at first 416,26.2 offset  0.0,0 rotate by 45 font ',7' front 'eb4206d'
set label 12 at first 420,26.2 offset  1.2,0 rotate by 45 font ',7' front '5a31873'
set label 13 at first 484,26.2 offset  0.0,0 rotate by 45 font ',7' front '77b3aac'
set label 14 at first 657,26.2 offset  0.0,0 rotate by 45 font ',7' front '118fb67'

plot \
  '< grep "(bash-[0-9]\{8\})" plot-rss.sh' u 2:($5/1024) lc rgb '#0000FF' title 'script set 1', \
  '< grep "(bash-[0-9]\{8\})" plot-rss.sh' u 2:($6/1024) lc rgb '#FF0000' title 'script set 2'
