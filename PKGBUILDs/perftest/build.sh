#!/bin/bash

fullname=$(curl 'https://www.openfabrics.org/downloads/perftest/latest.txt')
pkgver=$(echo $fullname | sed -n -e 's/^perftest-\([0-9.]*\)-.*$/\1/p')
subver=$(echo $fullname | sed -n -e 's/^perftest-[0-9.]*-\([0-9.]*\).\{16\}$/\1/p')
pkgkey=$(echo $fullname | sed -n -e 's/^.*\(.\{8\}\).\{7\}$/\1/p')
(
  echo "pkgname=perftest"
  echo "pkgver=$pkgver"
  echo "_pkgver_subver=$subver"
  echo "_pkgver_commit=$pkgkey"
  cat PKGBUILD0
) >PKGBUILD
makepkg -C -f
