#!/usr/bin/gnuplot

set terminal pngcairo color enhanced size 600,400
set ylabel 'Time [μs]'
set xlabel 'Length {/Times:Italic x}'
set log x
set log y
set key top left Left reverse

PlotScaling = " \
  PowerFitter(x, C, A) = C * (x ** A); \
  C1 = 0.000003; A1 = 2.0; fit [20000:*] PowerFitter(x, C1, A1) File u (6*$1):2 via A1,C1; \
  C2 = 0.040000; A2 = 1.0; fit [20000:*] PowerFitter(x, C2, A2) File u (6*$1):3 via A2,C2; \
  plot \
    PowerFitter(x, C1, A1) dt (16,16) lc rgb '#FF6666' t '', \
    PowerFitter(x, C2, A2) dt (16,16) lc rgb '#6666FF' t '', \
    File u (6*$1):2 lc rgb '#FF0000' t 'devel (fit: {/Times {/Times:Italic x}^{'.sprintf('%.3f', A1).'}})', \
    File u (6*$1):3 lc rgb '#0000FF' t 'patch (fit: {/Times {/Times:Italic x}^{'.sprintf('%.3f', A2).'}})'; "

set title '$\{v\^\}'
set output 'r0026a.png'
File = 'data1.txt'
eval PlotScaling

set title '$\{v\@U\}'
set output 'r0026b.png'
File = 'data2.txt'
eval PlotScaling

set title '$\{v//A\}'
set output 'r0026c.png'
File = 'data3.txt'
eval PlotScaling
