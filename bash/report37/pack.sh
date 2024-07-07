#!/usr/bin/env bash

# https://stackoverflow.com/questions/4698759/converting-git-repository-to-shallow
# https://stackoverflow.com/a/55352374/4908404
# https://stackoverflow.com/a/7937916/4908404

# Note: branch は全て tag に変換しておく。

function shallow-repository {
  git tag -d $(git tag -l | grep -Ev '0037|^extglob-')
  echo 55a83114200b86faf1dacffed036d7ea14d22b3f >.git/shallow
  git remote remove origin
}
function prune-repository {
  git reflog expire --expire=now --all
  git gc --prune=all
  git gc --prune=all
}

set -e

# git clone bash-dev  bash-r0037.1
# ( cd bash-r0037.1
#   shallow-repository
# )

# git clone bash-dev2 bash-r0037.2
# ( cd bash-r0037.2
#   shallow-repository
#   git remote add 1 ../bash-r0037.1
#   git push 1 --tags
# )

# ( cd bash-r0037.1
#   prune-repository
# )
