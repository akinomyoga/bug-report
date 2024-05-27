# -*- mode: sh-bash -*-

dir=reply202405/fpath
mkdir -p "$dir"

cat <<'EOF' > "$dir"/public1
internal1() { echo i1; }
internal2() { echo i2; }
public1() { printf p1; (($#)) && printf '<%s>' "$@"; echo; internal1; }
public2() { printf p2; (($#)) && printf '<%s>' "$@"; echo; internal1; internal2; }
$funcstack[1] "$@"
EOF

ln -sf public1 "$dir"/public2

fpath=$dir
autoload -U public1
autoload -U public2
