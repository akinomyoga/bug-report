#!/bin/bash

shopt -s extdebug

function hello {
  echo first_def
}

declare -F hello

if false; then
  function hello {
    echo second_def
  }
fi

function overwrite {
  function hello { echo second_def; }
}

declare -F hello
type hello

