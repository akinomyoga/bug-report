#!/usr/bin/env bash

# https://lists.gnu.org/archive/html/help-bash/2023-02/msg00158.html

# record() {
#   local -
#   set -m
#   while true; do
#     sleep 10 # ffmpeg http://some.url.m3u8
#   done & pgid_task="${!}"
# }

# sleep_while_recording() { sleep 30m; }

# record
# sleep_while_recording
# kill -INT -"$pgid_task"

# function task1 { for ((i=0;i<100000000;i++)); do :; done }
# function main {
#   local -
#   set -m
#   while true; do
#     task1 & task1 & wait
#   done & pgid=$!

#   sleep 3
#   ps -o pid,ppid,pgid,command | sort -n
#   echo "kill -INT -$pgid"
#   kill -INT -"$pgid"
#   sleep 1
#   ps -o pid,ppid,pgid,command | sort -n
#   sleep 2
#   echo end
# }
# main
