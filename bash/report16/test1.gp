#!/usr/bin/gnuplot

set terminal pngcairo font 'Times,20' size 600,400
set output 'test1.png'

fileA = 'test1.a.txt'
fileB = 'test1.b.txt'

a1 = 1; b1 = 1
func1(x) = a1 * (x ** b1)
a2 = 1; b2 = 1
func2(x) = a2 * (x ** b2)
fit [*:4e4] func1(x) fileA using 1:2:($2) yerrors via a1,b1
fit [4e4:*] func2(x) fileA using 1:2:($2) yerrors via a2,b2
a3 = 1; b3 = 1
func3(x) = a3 * (x ** b3)
fit [*:*] func3(x) fileB using 1:2:($2) yerrors via a3,b3

set ylabel 'Insertion time [{/Times:Italic μs}]'
set xlabel 'Number of keys'
set log x
set log y
set key left top
set yrange [100:*]
plot \
  fileA w p ps 2 pt 2 lc rgb 'black' t 'Before fix', \
  fileB w p ps 2 pt 6 lc rgb 'black' t 'After fix', \
  func1(x) lc rgb '#0000ff' t 'Fit 1 ({/Times:Italic α} = '.sprintf('%.2f', b1).')', \
  func2(x) lc rgb '#ff0000' t 'Fit 2 ({/Times:Italic α} = '.sprintf('%.2f', b2).')', \
  func3(x) lc rgb '#00ff00' t 'Fit 3 ({/Times:Italic α} = '.sprintf('%.2f', b3).')'
