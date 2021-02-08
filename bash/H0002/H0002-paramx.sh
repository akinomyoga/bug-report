
# set -u
# echo $hello; echo X

# echo ${hello?AA}; echo Y

shopt -s failglob
echo a*c; echo yes
echo no
