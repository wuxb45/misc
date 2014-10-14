#!/bin/bash

# $1: nr_cpus
# $2: memory size
gen_cpu_memory()
{
  echo "qemu-system-x86_64 -smp ${1} -m ${2} \
  -vga none -display none \
  -cpu host -machine accel=kvm -enable-kvm -daemonize "
}

# $1: port number: it will be added by 10000
gen_serial()
{
  ## you need to add "console=ttyS0" to guest's kernel parameters
  echo "-serial telnet:localhost:$((10000 + $1)),server,nowait"
}

# $1: port number: it will be added by 20000
gen_monitor()
{
  ## you need to add "console=ttyS0" to guest's kernel parameters
  echo "-monitor telnet:localhost:$((20000 + $1)),server,nowait"
}

# $1: brname
# $2: mac suffix, at most 65535
gen_bridge()
{
  local mac0=${MAC0:-00}
  local mac1=$(printf '%02x' $(($2 / 256)) )
  local mac2=$(printf '%02x' $(($2 % 256)) )
  echo "-net bridge,br=${1} -net nic,model=virtio,macaddr=52:54:00:${mac0}:${mac1}:${mac2}"
}

# $1 image file
# $2 image format
gen_disk()
{
  echo "-drive file=${1},if=virtio,aio=native,discard=on,format=${2}"
}

# $1 new image filename
# $2 new image format
# $3 base image filename
# $4 base image format
touch_cow()
{
  if [[ $# < 4 ]]; then
    echo "Usage: $0 <image> <format> <backing-image> <backing-format>"
    return 1
  fi
  if [[ ! -e "$1" ]]; then
    qemu-img create -f "$2" -o backing_file="$3",backing_fmt="$4" "$1"
    return $!
  else
    echo "found cow image $1"
    qemu-img info "$1"
    return $!
  fi
}

# $1: nr_cpus
# $2: memory size
# $3: unique index (it will be used for serial and macaddr)
# $4: brname
# $5: image filename (or the cow filename)
# $6: image format (or cow format)
# $7: base filename
# $8: base format
boot_one()
{
  if [[ $# != 6 && $# != 8 ]]; then
    echo "Usage: $0 <nr-CPUs> <mem-size> <unique-id> <brname> <image> <format> [<backing-image> <backing-format>]"
    return 1
  fi
  if [[ -n "$7" && -n "$8" ]]; then
    touch_cow "$5" "$6" "$7" "$8"
    if [[ $? != 0 ]]; then
      echo "touch_cow failed!"
      return $?
    fi
  fi
  $(gen_cpu_memory "$1" "$2") $(gen_serial "$3") $(gen_monitor "$3") $(gen_bridge "$4" "$3") $(gen_disk "$5" "$6")
}
