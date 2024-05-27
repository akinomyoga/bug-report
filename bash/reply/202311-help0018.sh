#!/bin/bash

setup()   { echo "setup()"  ; trap 'cleanup' INT TERM RETURN ; helper ; cleanup ; }
helper()  { echo "helper()" ; }
cleanup() { echo "cleanup() caller=${FUNCNAME[1]}" ; trap - INT TERM RETURN ; }
main()    { echo "main()"   ; setup ; helper ; }

declare -ft cleanup

main
