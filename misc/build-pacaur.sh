#!/bin/bash
sudo pacman -S --needed wget curl openssl yajl expac git sudo
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
rm -rf /tmp/cower
rm -rf /tmp/pacaur
(
  cd /tmp
  wget https://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz
  tar -xf cower.tar.gz
  cd cower
  makepkg -i
)
(
  cd /tmp
  wget https://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz
  tar -xf pacaur.tar.gz
  cd pacaur
  makepkg -i
)
