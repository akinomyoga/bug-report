#!/bin/bash

WIKI_DIR=$1

shopt -s lastpipe
find "$WIKI_DIR" -type f -print0 | # 1 fork, 1 exec
  mapfile -d '' -t filenames
printf '%s\0' "${filenames[@]}" |  # 1 fork
  xargs -0 -P 1 file -b |          # 1 fork, 1 exec
  mapfile -t filetypes
executables=()
normalfiles=()
for ((i=0;i<${#filenames[@]};i++)); do
  case ${filetypes[i]} in
  (*executable*|*script*) executables+=("${filenames[i]}") ;;
  (*)                     normalfiles+=("${filenames[i]}") ;;
  esac
done
((${#executables[@]})) && echo chmod u=rwx,g=rx,o= "${executables[@]}" # 1 fork
((${#normalfiles[@]})) && echo chmod u=rw,g=r,o=   "${normalfiles[@]}" # 1 fork

# # Make Python, PHP and friends executable
# IFS= find "$WIKI_DIR" -type f -print | while read -r file; do
#   if file -b "${file}" | grep -q -E 'executable|script'; then
#     chmod u=rwx,g=rx,o= "${file}"
#   else
#     chmod u=rw,g=r,o= "${file}"
#   fi
# done
