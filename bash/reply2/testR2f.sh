function Dummy {
  [[ $1 == refArray ]] || local -n refArray=$1
  [[ $1 == myArray ]] || local -ia myArray=("${refArray[@]}")
  myArray[0]=${myArray[0]%/}
}
myArray=(my/dir/)
declare -p myArray
Dummy myArray
declare -p myArray
