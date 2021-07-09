#!/bin/bash

set -T
trap 'previous_command=$this_command; this_command=$BASH_COMMAND' DEBUG

function hello {
  false fdsafdsafdsafdsa || { echo "previous: $previous_command"; return 1; }
}
hello

# function myeval {
#   local __command=$1
#   eval "$__command"; local __exit_status=$?
#   ((__exit_status)) && echo "$__command"
#   return "$__exit_status"
# }

# function hello {
#   myeval 'false fdsafdsafdsafdsa' || return 1
# }
# hello
