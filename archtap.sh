#/bin/bash

#### update kernel
#sudo pacman -Sy
linuxi=$(pacman -Qu | grep 'linux ')
if [ -z $linuxi ]; then
  echo No new Kernel.
  #exit 0
else
  echo New Kernel available.
fi

read -p "Build kernel[y/n]?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]];then
  ABSROOT=. abs core/linux; cd core/linux
  echo "Entering $(pwd)"
  makepkg --verifysource

  echo '
CONFIG_DEBUG_INFO=y
CONFIG_DEBUG_INFO_REDUCED=n
' >> config.x86_64
  makepkg --skipchecksums
  echo Build done.
  read -p "Install kernel[y/n]?" -n 1 -r
  if [[ $REPLY =~ ^[Yy]$ ]];then
    pacman -U *.pkg.tar.xz
  fi
fi
