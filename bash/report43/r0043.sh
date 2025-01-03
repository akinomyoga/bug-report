#!/usr/bin/env bash

declare -a a
declare -A d

#------------------------------------------------------------------------------
# These are the test cases for the problem that commit 194cfc28 tried to fix.
# Actually, the fix in commit 194cfc28 was incomplete since the problem still
# persisted for associative arrays with `assign_func' set, such as
# BASH_ALIASES (see case #3, #6, and #9).

# case #1: swap indexed-array elements
a=([0]=X [1]=Y)
a=([0]="${a[1]}" [1]="${a[0]}")
[[ ${a[0]},${a[1]} == Y,X ]] || echo '#1 fail'

# case #2: swap associative-array elements.
d=([0]=X [1]=Y)
d=([0]="${d[1]}" [1]="${d[0]}")
[[ ${d[0]},${d[1]} == Y,X ]] || echo '#2 fail'

# case #3: swap associative-array elements with `assign_func'.
BASH_ALIASES=([a]=X [b]=Y)
BASH_ALIASES=([a]="${BASH_ALIASES[b]}" [b]="${BASH_ALIASES[a]}")
[[ ${BASH_ALIASES[a]},${BASH_ALIASES[b]} == Y,X ]] || echo '#3 fail'

# case #4: swap indexed-array elements with a builtin
a=([0]=X [1]=Y)
declare -a a=([0]="${a[1]}" [1]="${a[0]}")
[[ ${a[0]},${a[1]} == Y,X ]] || echo '#4 fail'

# case #5: swap associative-array elements.
# Note: This is what commit 194cfc28 attempted to fix with a builtin
d=([0]=X [1]=Y)
declare -A d=([0]="${d[1]}" [1]="${d[0]}")
[[ ${d[0]},${d[1]} == Y,X ]] || echo '#5 fail'

# case #6: swap associative-array elements with `assign_func' with a buitlin
BASH_ALIASES=([a]=X [b]=Y)
declare -A BASH_ALIASES=([a]="${BASH_ALIASES[b]}" [b]="${BASH_ALIASES[a]}")
[[ ${BASH_ALIASES[a]},${BASH_ALIASES[b]} == Y,X ]] || echo '#6 fail'

# case #7: swap indexed-array elements with a builtin without the type flag
a=([0]=X [1]=Y)
declare a=([0]="${a[1]}" [1]="${a[0]}")
[[ ${a[0]},${a[1]} == Y,X ]] || echo '#7 fail'

# case #8: swap associative-array elements. with a builtin without the type
# flag
d=([0]=X [1]=Y)
declare d=([0]="${d[1]}" [1]="${d[0]}")
[[ ${d[0]},${d[1]} == Y,X ]] || echo '#8 fail'

# case #9: swap associative-array elements with `assign_func' with a builtin
# without the type flag
BASH_ALIASES=([a]=X [b]=Y)
declare BASH_ALIASES=([a]="${BASH_ALIASES[b]}" [b]="${BASH_ALIASES[a]}")
[[ ${BASH_ALIASES[a]},${BASH_ALIASES[b]} == Y,X ]] || echo '#9 fail'

#------------------------------------------------------------------------------
# These are the test cases for the present problem, which was introduced by
# commit 194cfc28

# case #10: compound append in indexed arrays
a=([0]=old)
a=([0]=new1 [0]+=new2)
[[ ${a[0]} == new1new2 ]] || echo '#10 fail'

# case #11: compound append in associative arrays
d=([0]=old)
d=([0]=new1 [0]+=new2)
[[ ${d[0]} == new1new2 ]] || echo '#11 fail'

# case #12: compound append in indexed arrays with builtin
a=([0]=old)
declare -a a=([0]=new1 [0]+=new2)
[[ ${a[0]} == new1new2 ]] || echo '#12 fail'

# case #13: compound append in associative arrays with builtin
d=([0]=old)
declare -A d=([0]=new1 [0]+=new2)
[[ ${d[0]} == new1new2 ]] || echo '#13 fail'
