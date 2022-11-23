# -*- mode: makefile-gmake -*-

.PHONY: all
all:

# all: fnmatch
# fnmatch: fnmatch.c
# 	gcc -O2 -o $@ $<

all: fnmatch.so
fnmatch.so: fnmatch_builtin.c
	gcc -O2 -fPIC -shared -o $@ $<
all: strmatch.so
strmatch.so: strmatch_builtin.c
	gcc -O2 -fPIC -shared -o $@ $<
