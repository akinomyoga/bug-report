#!/bin/bash
#while (
  cleanup() {
    tput rmcup
    exit 0
  }
  trap cleanup SIGINT
  while ! read -t0.01 -n1; do : ; done
#); do :; done
