#!/bin/bash

# https://lists.gnu.org/archive/html/bug-bash/2020-10/msg00095.html

# tot=0
# for i in {1..100} ;do
#   rt=${EPOCHREALTIME//.}
#   read -t .000001 foo
#   ((tot+=${EPOCHREALTIME//.}-rt))
#   printf $'\r\e[Ki=%d' "$i"
#   sleep .002
# done
# echo
# echo ${tot:: -2}.${tot: -2}

# tot=0
# for i in {1..100} ;do
#   rt=${EPOCHREALTIME//.}
#   read -t .000001 foo
#   ((tot+=${EPOCHREALTIME//.}-rt))
#   printf $'\r\e[Ki=%d' "$i"
# done < <(while :;do sleep 1;echo;done)
# echo
# echo ${tot:: -2}.${tot: -2}

# https://lists.gnu.org/archive/html/bug-bash/2020-11/msg00002.html
function bug-bash/2020-11/msg00002 {
  declare -p BASH_VERSI{NFO,ON}
  uptime
  uname -a
  po() {
    for f in {1..10000};do
      read -t .000001 v
      rc=$?
      [ $rc -ne 142 ] || [ "$v" ] &&
        echo f:$f, v:$v, RC:$rc.
    done < <(for i in {1..10000};do sleep 3;echo Timed;done)
  }
  exec 2>&1
  TIMEFORMAT="U:%U S:%S R:%R"
  for test in {1..20};do
    time po
  done
}
#bug-bash/2020-11/msg00002


#!/bin/bash

declare -p BASH_VERSI{NFO,ON}
uptime
uname -a
innerLoop=${1:-3000}
trap "echo -n ." SIGCHLD
po() {
  for ((f=0;f<innerLoop;f++));do
    read -u 9 -t .000001 v
    rc=$?
    [ $rc -ne 142 ] || [ "$v" ] &&
      echo f:$f, v:$v, RC:$rc.
  done
}
exec 9< <(for i in {1..1000};do sleep 1;: echo Timed;done)
exec 2>&1
TIMEFORMAT="U:%U S:%S R:%R"
for test in {1..100};do
  time po
done
exit 0
