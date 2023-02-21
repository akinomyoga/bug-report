#!/bin/bash

# df8375c NG
# 987daba OK
# git bisect start df8375c 987daba
# git bisect run ./bisect.sh

#git bisect start f9f8a7fa 3e03eaff

mkd() { [[ -d $1 ]] || mkdir -p "$1"; }

rebuild() {
  local -x hash=$(git rev-parse HEAD)
  local cache=bisect-bin/bash.$hash
  if [[ -s $cache && -x $cache ]]; then
    cp "$cache" ./bash || return 1
  else
    mkd bisect-bin || return 1

    (
      # Clean up
      rm -f ./bash
      make -j clean
      make distclean

      # Build
      git reset --hard &&
        { [[ $1 == no-release ]] ||
            sed -i 's/define(relstatus, .*)/define(relstatus, release)/' configure.ac; } &&
        { autoreconf -i; ./configure; } &&
        { make -j all || make -j all || make all || make all; } &&
        rm -f parser-built y.tab.c y.tab.h &&
        git reset --hard || return 1

      # Cache binary
      [[ -s bash && -x bash ]] &&
        cp ./bash "$cache" &&
        touch --date="$(git show -s --format=%ci @)" "$cache" &&
        "$cache" -c 'echo "bash.$hash $BASH_VERSION ($MACHTYPE)"' >> bisect-bin/versions || return 1
    ) >> "$cache.log" 2>&1
  fi
}

case $1 in
(rebuild)
  rebuild || rebuild no-release ;;
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
    rebuild || rebuild no-release || exit 125
    eval "$_bisect_command"
  fi ;;
esac

#lastline=$(timeout 30 ./bash bisect1.sh | grep -q false)
#[[ $lastline == 'ok 3000' ]]
#./bash bisect1.sh | grep -q false

# ./bisect.sh start ./bisect3.sh 407d9afc 9b44e16c6f
