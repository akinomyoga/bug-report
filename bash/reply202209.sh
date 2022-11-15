#!/usr/bin/env bash

shopt -s extglob

# 何れも本質的には N^3

#printf -v a '%.1s ' {1..309} # 618ch
#printf -v a '%.3s ' {001..165} # 660ch
#printf -v a '%s ' {1..188} # 644ch
# echo ${#a}
# time : "${a//?([$' \t\n'])}"

# printf -v a '%*s' 2000
# time : "${a//' '?([$'\t\n'])}"
# time : "${a//' '?(x)/x}"

#a=$(gcc --help)
#a=${a::1000}
#time a=${a//+([$' \t\n'])}
printf -v a 'x%.0s\n' {1..300} # 600ch
time a=${a//+([$' \t\n'])}
