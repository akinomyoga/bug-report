#!/bin/bash

setexit() { return "$1"; }
invoke() { kill -USR1 $$; return 222; }

trap 'setexit 111; return' USR1
invoke
case $? in
0)   echo 'In trap argument: last command preceding the trap action' ;;
111) echo 'In trap argument: last command in the trap action' ;;
222) echo 'In trap argument: (failed to exit the function)' ;;
*)   echo 'In trap argument: (unexpected)' ;;
esac

stat=99
handler() { setexit 111; return; }
trap 'handler; stat=$?; return' USR1
invoke
case $stat in
0)   echo 'In direct function call: last command preceding the trap action' ;;
111) echo 'In direct function call: last command in the trap action' ;;
*)   echo 'In direct function call: (unexpected)' ;;
esac

stat=99
utility2() { setexit 111; return; }
handler2() { utility2; stat=$?; }
trap 'handler2' USR1
invoke
case $stat in
0)   echo 'In indirect function call: last command preceding the trap action' ;;
111) echo 'In indirect function call: last command in the trap action' ;;
*)   echo 'In indirect function call: (unexpected)' ;;
esac

trap 'false && echo ERROR || echo OK' USR1
invoke
