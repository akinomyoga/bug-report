#!/bin/sh

expect -c '
spawn /bin/sh hello.sh
expect "Name:"
send "world\n"
expect "Hello!"
expect $
'
