#!/bin/bash

# run as root (or sudo)

# files
find /usr | sort >/tmp/.allf
# tracked files
pacman -Qlq | grep '^/usr' | sed 's/\/$//' | sort | uniq >/tmp/.pacf
# diff
comm -23 /tmp/.allf /tmp/.pacf | grep -v '^/usr/local' | vim -
rm /tmp/.allf /tmp/.pacf
