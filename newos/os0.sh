#!/bin/bash

if [[ -z ${1} ]]; then
  echo "Usage: ./os0.sh <sdX>"
  exit 0
fi

wipefs -a -f -q /dev/${1}
echo "o\nn\n\n\n\n\n\nw\n" | fdisk /dev/${1}

mkfs.xfs /dev/${1}1
mount /dev/${1}1 /mnt

./os1.sh "/mnt" ${1}

sync
umount /mnt
