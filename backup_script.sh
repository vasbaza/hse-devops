#!/bin/bash

log="error.log"

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
  -d | --directory)
    directory="$2"
    shift # past argument
    shift # past value
    ;;
  -c | --compression)
    compression="$2"
    shift # past argument
    shift # past value
    ;;
  -o | --output)
    output="$2"
    shift # past argument
    shift # past value
    ;;
  -*)
    echo "Unknown option $1" 2>$log
    exit 1
    ;;
  *)
    POSITIONAL_ARGS+=("$1") # save positional arg
    shift                   # past argument
    ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

if [[ -n $1 ]]; then
  echo "Last line of file specified as non-opt/last argument:" 2>$log
  tail -1 "$1" 2>$log
  exit 1
fi

case "$compression" in
"none")
  tar -cf "$output" "$directory" 2>$log
  ;;
"bzip")
  tar -cjf "$output" "$directory" 2>$log
  ;;
"xz")
  tar -cJf "$output" "$directory" 2>$log
  ;;
"gzip")
  tar -czf "$output" "$directory" 2>$log
  ;;
"lzip")
  tar -cf --lzip "$output" $directory 2>$log
  ;;
"lzma")
  tar -cf --lzma "$output" "$directory" 2>$log
  ;;
"lzop")
  tar -cf --lzop "$output" "$directory" 2>$log
  ;;
*)
  echo "No such type of compression $compression" 2>$log
  exit 1
  ;;
esac

openssl aes-256-cbc -a -salt -pbkdf2 -in "$output" -out "$output" 2>$log
