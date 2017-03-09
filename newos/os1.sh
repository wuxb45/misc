#!/bin/bash
rm -f pkgs os2.sh
wget -q http://141.217.24.182/what/pkgs
wget -q http://141.217.24.182/what/os2.sh

if [[ -z ${1} ]]; then
  echo "Usage: ./os1.sh sdX"
  exit 0
fi

mkfs.xfs /dev/${1}1
mount /dev/${1}1 /mnt

pacstrap /mnt $(cat pkgs)
genfstab -pU /mnt > /mnt/etc/fstab
cp os2.sh /mnt/root/os2.sh
chmod +x /mnt/root/os2.sh
arch-chroot /mnt /root/os2.sh ${1}

sync
umount /mnt
