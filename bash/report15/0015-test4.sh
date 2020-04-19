#!/bin/bash

setexit() { return "$1"; }
invoke() { kill -USR1 $$; return 222; }

trap 'setexit 111; return' USR1
invoke
case $? in
(0)   echo 'In trap argument: last command preceding the trap action' ;;
(111) echo 'In trap argument: last command in the trap action' ;;
(222) echo 'In trap argument: (failed to exit the function)' ;;
(*)   echo 'In trap argument: (unexpected)' ;;
esac

stat=99
handler() { setexit 111; return; }
trap 'handler; stat=$?; return' USR1
invoke
case $stat in
(0)   echo 'In function call: last command preceding the trap action' ;;
(111) echo 'In function call: last command in the trap action' ;;
(*)   echo 'In function call: (unexpected)' ;;
esac
