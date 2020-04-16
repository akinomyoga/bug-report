#!/bin/bash

setexit() { return "$1"; }
trap 'setexit 222; return' USR1

process() { kill -USR1 $$; }
process
echo exit=$?
