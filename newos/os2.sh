#!/bin/bash
TZ="America/Chicago"

pacman -R --noconfirm vi
ln -s /usr/bin/vim /usr/bin/vi
passwd
vi /etc/hostname
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
systemctl enable sshd systemd-timesyncd
ln -sf /usr/share/zoneinfo/$TZ /etc/localtime

if [[ -n ${1} ]]; then
  grub-install /dev/${1}
  grub-mkconfig >/boot/grub/grub.cfg
fi
