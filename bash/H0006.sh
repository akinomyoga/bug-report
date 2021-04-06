
function test1 {
  function read-timeout {
    local _read_timeout_buffer=
    local _read_timeout_c
    while IFS= read -t "$1" -r -n 1 _read_timeout_c || [[ $_read_timeout_c ]]; do
      _read_timeout_buffer+=$_read_timeout_c
    done
    read "${@:2}" <<< "$_read_timeout_buffer"
  }
  read-timeout 2 -r x < <(echo -n a; sleep 1; echo -n b; sleep 1; echo -n c; sleep 1; echo -n d)
  echo $?
  echo "[$x]"
}

function test2 {
  declare -A x=([a]=1 [b]=2)
  def=${x[@]@A}
  eval "${def/ x=/ y=}"
  declare -p y

  declare -A x=([a]=1 [b]=2)
  def=${x[@]@A}
  eval "declare -A z=${def#*=}"
  declare -p z
}


urlencode() {
  local LC_ALL= LC_CTYPE=C LC_COLLATE=C

  local i length=${#1}
  for ((i=0;i<length;i++)); do
    local c=${1:i:1}
    case $c in
    ([a-zA-Z0-9.~_-]) printf '%s' "$c" ;;
    (*) printf '%%%02X' "'$c" ;;
    esac
  done
}

urldecode() {
    # urldecode <string>
    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\\x}"
}

urlencode α
