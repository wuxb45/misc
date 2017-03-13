#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: ./os1.sh <root-dir> [<dev>]"
  exit 0
fi

pacstrap ${1} $(cat pkgs)
genfstab -pU ${1} > ${1}/etc/fstab
cp os2.sh ${1}/root/os2.sh
chmod +x ${1}/root/os2.sh
arch-chroot ${1} /root/os2.sh ${2}
