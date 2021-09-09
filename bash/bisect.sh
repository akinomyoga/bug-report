#!/bin/bash

# df8375c NG
# 987daba OK
# git bisect start df8375c 987daba
# git bisect run ./bisect.sh

#git bisect start f9f8a7fa 3e03eaff

rebuild() {
  # Build
  make -j clean
  make distclean
  git reset --hard
  sed -i 's/define(relstatus, .*)/define(relstatus, release)/' configure.ac
  autoreconf -i
  ./configure
  make -j all || make -j all
  make all || make all
  rm -f parser-built y.tab.c y.tab.h
  git reset --hard
}

case $1 in
(rebuild)
  rebuild ;;
(test)
  if [[ $3 ]]; then
    if ! git checkout "$3"; then
      echo "failed to checkout $2" >&2
      exit 1
    fi
  fi
  _bisect_command=$2
  rebuild
  eval "$_bisect_command";;
(start)
  # ./bisect.sh start ./test.sh NEW_COMMIT OLD_COMMIT
  git bisect start "$3" "$4"
  _bisect_command=$2 git bisect run ./bisect.sh ;;
(*)
  if [[ $_bisect_command ]]; then
    rebuild
    eval "$_bisect_command"
  fi ;;
esac

#lastline=$(timeout 30 ./bash bisect1.sh | grep -q false)
#[[ $lastline == 'ok 3000' ]]
#./bash bisect1.sh | grep -q false

