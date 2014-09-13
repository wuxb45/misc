#!/bin/bash

# $1 memory size
gen_common()
{
  echo "qemu-system-x86_64 -m ${1} \
  -vga none -display none -monitor none \
  -cpu host -machine accel=kvm -enable-kvm -daemonize "
}

# $1 port number: it will be added by 10000
gen_serial()
{
  ## you need to add "console=ttyS0" to guest's kernel parameters
  echo "-serial telnet:localhost:$((10000 + $1)),server,nowait"
}

# $1 image file
# $2 image format
gen_disk()
{
  echo "-drive file=${1},if=virtio,aio=native,discard=on,format=${2}"
}

# $1: brname
# $2: mac suffix, at most 65535
gen_bridge()
{
  local mac1=$(printf '%02x' $(($2 / 256)) )
  local mac2=$(printf '%02x' $(($2 % 256)) )
  echo "-net bridge,br=${1} -net nic,model=virtio,macaddr=52:54:00:00:${mac1}:${mac2}"
}

# $1 new image filename
# $2 new image format
# $3 base image filename
# $4 base image format
create_cow()
{
  if [[ $# < 4 ]]; then
    echo "usage: $0 <image> <format> <backing-image> <backing-format>"
    return 1
  fi
  qemu-img create -f "$2" -o backing_file="$3",backing_fmt="$4" "$1"
  return $!
}

# $1 memory size
# $2 unique index (it will be used for serial and macaddr)
# $3 brname
# $4 image filename (or the cow filename)
# $5 image format (or cow format)
# [$6 base filename
# $7] base format
boot_one()
{
  if [[ $# != 5 && $# != 7 ]]; then
    echo "Usage: $0 <mem-size> <unique-id> <brname> <image> <format> [<backing-image> <backing-format>]"
    return 1
  fi
  if [[ -n $6 && -n $7 ]]; then
    create_cow "$4" "$5" "$6" "$7"
    if [[ $? != 0 ]]; then
      echo "create_cow failed!"
      return $?
    fi
  fi
  $(gen_common "$1") $(gen_serial "$2") $(gen_bridge "$3" "$2") $(gen_disk "$4" "$5")
}
