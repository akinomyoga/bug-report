#!/bin/bash

# df8375c NG
# 987daba OK

# git bisect start df8375c 987daba

# Build
make -j clean
make distclean
git reset --hard
#sed -i 's/define(relstatus, .*)/define(relstatus, release)/' configure.in
#autoreconf -i
./configure
make -j all
make all
rm -f parser-built y.tab.c y.tab.h
git reset --hard

lastline=$(timeout 30 ./bash bisect_read_timeout1.sh | tee /dev/stderr | tail -1)

[[ $lastline == 'ok 3000' ]]
