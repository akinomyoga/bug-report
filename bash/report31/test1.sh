#!/bin/bash

str='X&Y&Z' pat='Y' rep='A&B'
echo "1:${str/$pat/"$rep"}"
echo "3:${str/$pat/${rep//&/\\\\&}}"

echo ----------------------------------------

v='A' p='?'; echo "${v/$p/B}"; echo "${v/"$p"/B}"
v='A' p='#'; echo "${v/$p/B}"; echo "${v/"$p"/B}"
v='A' p='%'; echo "${v/$p/B}"; echo "${v/"$p"/B}"


echo ----------------------------------------

value='a*b*c' globchars='\*?[('
escaped=${value//["$globchars"]/'\'&}
echo "$escaped"


echo "1:${value//["$globchars"]/'\'&}"

echo "2a:${value//["$globchars"]/&}"
echo "2b:${value//["$globchars"]/\&}"
echo "2c:${value//["$globchars"]/\\&}"
echo "2d:${value//["$globchars"]/\\\&}"
echo "2e:${value//["$globchars"]/\\\\&}"
echo "2f:${value//["$globchars"]/\\\\\&}"
echo "2g:${value//["$globchars"]/\\\\\\&}"

backslash='\'
echo "3a:${value//["$globchars"]/$backslash&}"
echo "3b:${value//["$globchars"]/"$backslash"&}"
