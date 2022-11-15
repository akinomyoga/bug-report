#!/bin/bash

# bash-dev -c 'for i in {0..999}; do (trap "rm -rf $BASHPID.tmp" EXIT; >| "$BASHPID.tmp") done'

# for i in {0..999}; do
#   (
#     pid=$BASHPID
#     cleanup() { if ((pid==BASHPID)); then rm -rf "$pid.tmp"; fi }
#     trapint() { cleanup; trap - INT; kill -INT "$BASHPID"; }
#     trap cleanup EXIT
#     trap trapint INT
#     >> "$pid.tmp"
#   )
# done

for i in {0..999}; do
  (
    tmp=$BASHPID.tmp
    cleanup() { rm -rf "$tmp"; }
    trapint() { cleanup; trap - INT; kill -INT "$BASHPID"; }
    trap cleanup EXIT
    trap trapint INT
    >> "$tmp"
  )
done
