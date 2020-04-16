#!/bin/bash

check() { false; return; }
handle() { check && echo Unexpected; }
trap handle USR1
kill -USR1 $$
