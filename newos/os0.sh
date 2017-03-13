#!/bin/bash

if [[ -z ${1} ]]; then
  echo "Usage: ./os0.sh <sdX>"
  exit 0
fi

wipefs -a -f -q /dev/${1}
#echo "o\nw\n" | fdisk /dev/${1}
#partprobe
echo 'start=2048, type=83' | sfdisk /dev/${1}
partprobe
mkfs.xfs -f /dev/${1}1
mount /dev/${1}1 /mnt

./os1.sh "/mnt" ${1}

sync
umount /mnt
