#!/bin/bash
keyfile=$1
if [[ ! -e $keyfile ]]; then
  echo no such file
  echo "usage: $0 <keyfile>"
  exit 0
fi

k=$(cat $keyfile)
for i in $(seq 1 254); do
  echo "v$(printf '%02x' $i),10.10.10.$i $k"
done
