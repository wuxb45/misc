#!/bin/bash

Y=$(date +%Y)

statdir ()
{
  local y=$(( 1 + $Y))
  for i in $(seq 1 50); do
    if [[ -d ${1}/${y} ]]; then
      echo "${y}  ${1}"
      return
    fi
    y=$(($y - 1))
  done
  echo "????  ${1}"
}


(for conf in $(ls); do
  if [[ -d ${conf} ]]; then
    statdir ${conf}
  fi
done) | sort
