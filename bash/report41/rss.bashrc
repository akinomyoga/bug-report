# bashrc

HISTFILE=A
get-mem() { ret=$(ps -o rss $$ | tail -1); }
get-mem; m1=$ret
source ~/.mwg/src/ble.sh/out/ble.sh --norc --attach=attach

run1() {
  get-mem; m2=$ret
  set -o vi
}

run2() {
  get-mem; m3=$ret
  printf '%s\n' "$_ble_bash blesh=$((m2-m1)), with-vim=$((m3-m1))" | tee -a rss.txt >/dev/tty
  exit
}
