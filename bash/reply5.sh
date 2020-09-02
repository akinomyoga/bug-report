#!/bin/bash

for a in {1..5}; do
  echo "Begin a=$a"
  for b in {1..5}; do
    echo "Begin b=$b"
    ((b==2)) && continue 2
    echo "End b=$b"
  done
  echo End a
done
