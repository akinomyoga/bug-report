#!/usr/bin/zsh

__module__=mylib.util.example

function $__module__.func1 { echo func1; }
function $__module__.func2 { echo func1; }

declare -f "$__module__.func1"
declare -f mylib.util.example.func2
