#!/bin/bash
TZ="America/Chicago"
DEV=/dev/${1}

pacman -R --noconfirm vi
ln -s /usr/bin/vim /usr/bin/vi
passwd
vi /etc/hostname
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
systemctl enable sshd systemd-timesyncd
ln -s /usr/share/zoneinfo/$TZ /etc/localtime
grub-install ${DEV}
grub-mkconfig >/boot/grub/grub.cfg
