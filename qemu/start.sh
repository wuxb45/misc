#!/bin/bash
# usage :
#   empty parameters: start base.qed
#   <number>: start <number> COW qemu instances based on base.qed
# get number of instances
nr=$1
if [[ ! $nr =~ ^-?[0-9]+$ ]]; then
  nr=
elif [[ $nr -gt 250 ]]; then
  echo $nr is too large
  exit 0
fi

if [[ ! -e base.qed ]]; then
  echo base.qed not found
  exit 0
fi


msize=512M
qemu_common="qemu-system-x86_64 -m ${msize} \
  -vga none -display none -monitor none \
  -cpu host -machine accel=kvm -enable-kvm -daemonize "

gen_serial()
{
  ## you need to add "console=ttyS0" to guest's kernel parameters
  echo "-serial telnet:localhost:111$(printf '%02d' $1),server,nowait"
}

gen_disk()
{
  echo "-drive file=${1},if=virtio,aio=native,discard=on,format=qed"
}

gen_bridge()
{
  echo "-net bridge,br=${br} -net nic,model=virtio,macaddr=52:54:00:00:00:$(printf '%02x' $1)"
}

if [ -z $nr ]; then
  echo "Starting one qemu instance using default network"
  $qemu_common \
  $(gen_disk base.qed) \
  $(gen_serial 0) \
  #
else
  echo "Starting $nr qemu instances in private network"
  br=br0
  for i in $(seq 1 $nr); do
    incr=incr${i}.qed
    rm -rf ${incr}
    qemu-img create -f qed ${incr} -b base.qed
    $qemu_common \
      $(gen_disk ${incr}) \
      $(gen_bridge $i) \
      $(gen_serial $i) \
      #
  done
fi
