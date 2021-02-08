#!/bin/bash

input=$1

# Check the input file
if (($#==0)); then
  echo "usage: minify.sh scriptfile" >&2
  exit 2
elif [[ ! -r $1 ]]; then
  echo "minify.sh: Cannot read '$input'." >&2
  exit 1
elif ! bash -n -O extglob "$input"; then
  echo "minify.sh: Failed in the syntax check of '$input'." >&2
  exit 1
fi

# Determine the output filename
shopt -s extglob
count=
while output=${input%.@(sh|bash)}.min$count.sh; [[ -e $output || -L $output ]]; do
  ((count++))
done

# Parse & Print
eval $'content(){\n'"$(< "$input")"$'\n}'
declare -pf content | head -n -1 | tail -n +3 > "$output"
