
#shopt -s extglob

dir=/foo/bar/baz///
separator1=/
separator2=\057
number0=*
number1=+
pattern1="${number1}(${separator1})"
pattern2="${number0}([${separator2}])"
base=///grimble/pritz
path1=${dir%%${pattern1}}${separator1}${base##${pattern2}}
path2=${dir/%${pattern1}/${separator1}}${base/#${pattern2}/}
declare -p "${!path@}"

slash=/
pattern1='+(/)'
pattern2='*(/)'
a=A//
b=//B
text1=${a%%${pattern1}}
text2=${b##${pattern2}}
text3=${a/%${pattern1}/${slash}}
text4=${b/#${pattern2}/${slash}}
declare -p "${!text@}"


shopt -s extglob
d=//A// pat1='+(/)' pat2='*(/)'
echo "${d%%$pat1}, ${d##$pat2}"
