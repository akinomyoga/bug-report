#!/bin/bash

f1() {
  echo stderr 1>&2
  echo stdout
}

echo cumbersome
{ f1 3>&1 1>&2 2>&3 |
  awk -e '{ print "awk1: ", $0 }'; } 2>&1 |
  awk -e '{ print "awk2: " $0 }'

echo pipesubst
source pipesubst.sh
pipesubst 'f1 2>&$fd1' \
          $'> awk \'{ print "awk1: ", $0 }\'' |
  awk '{ print "awk2: " $0 }'
