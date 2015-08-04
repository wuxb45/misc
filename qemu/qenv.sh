#!/bin/bash
case ${1} in
run)
  dowhat=run_sys
  ;;
gen)
  dowhat=gen_sys
  ;;
*)
  echo "usage: $0 {run|gen} <config-file>"
  exit 0
esac

if [[ -e "${2}" ]]; then
  . ${2}
else
  echo "## empty configuration"
fi

# local_id=0-n
# display=none
gen_display()
{
  local _local_id=${local_id:-0}
  if [[ ${display} == "none" ]]; then
    echo "-vga none -display none "
  elif [[ ${display} == "vnc" ]]; then
    echo "-vga vmware -display vnc=0.0.0.0:${_local_id} "
  fi
}

# nr_cpus=1-n
# mem_size=1M,1G
gen_cpu_memory()
{
  local _nr_cpus=${nr_cpus:-1}
  local _mem_size=${mem_size:-256M}
  echo "-smp ${_nr_cpus} -m ${_mem_size} -cpu host -machine accel=kvm -enable-kvm -daemonize "
}

# local_id=0-n
gen_serial()
{
  local _local_id=${local_id:-0}
  ## you need to add "console=ttyS0" to guest's kernel parameters
  echo "-serial telnet:localhost:$((10000 + ${_local_id})),server,nowait"
}

# local_id=0-n
gen_monitor()
{
  local _local_id=${local_id:-0}
  echo "-monitor telnet:localhost:$((20000 + ${_local_id})),server,nowait"
}

# bridge=br0
# mac3=00-ff
# mac4=00-ff
# mac5=00-ff
# mac6=00-ff
gen_bridge()
{
  if [[ -n ${bridge} ]]; then
    local _mac3=${mac3:-00}
    local _mac4=${mac4:-00}
    local _mac5=${mac5:-00}
    local _mac6=${mac6:-00}
    local _model=${nic_model:-virtio}
    echo "-net bridge,br=${bridge} -net nic,model=${_model},macaddr=52:54:${_mac3}:${_mac4}:${_mac5}:${_mac6} "
  fi
}

gen_boot()
{
  if [[ -n ${boot} ]]; then
    echo "-boot ${boot} "
  fi
}

gen_cdrom()
{
  if [[ -n ${cdrom} ]]; then
    echo "-cdrom ${cdrom} "
  fi
}

# main_img=
# main_fmt=
gen_disks()
{
  for i in $(seq 0 4); do
    local cache=${cache_mode[${i}]:-writeback}
    local aio="threads"
    if [[ ${cache} == "none" || ${cache} == "directsync" ]]; then
      aio="native"
    fi
    if [[ -n ${base_img[${i}]} && -n ${base_fmt[${i}]} ]]; then
      if [[ -n ${cow_img[${i}]} && -n ${cow_fmt[${i}]} ]]; then
        echo "-drive file=${cow_img[${i}]},if=virtio,aio=${aio},discard=on,format=${cow_fmt[${i}]},cache=${cache} "
      else
        echo "-drive file=${base_img[${i}]},if=virtio,aio=${aio},discard=on,format=${base_fmt[${i}]},cache=${cache} "
      fi
    fi
  done
}

# base_img[]
# base_fmt[]
# base_cap[]
# cow_img[]
# cow_fmt[]
touch_imgs()
{
  for i in $(seq 0 4); do
    if [[ -n ${base_img[${i}]} && -n ${base_fmt[${i}]} && -n ${cow_img[${i}]} && -n ${cow_fmt[${i}]} ]]; then
      if [[ ! -e "${base_img[${i}]}" ]]; then
        echo "[touch_cow] base_img ${base_img[${i}]} not found!"
        exit 1
      fi
      if [[ ! -e "${cow_img[${i}]}" ]]; then
        qemu-img create -f "${cow_fmt[${i}]}" -o backing_file="${base_img[${i}]}",backing_fmt="${base_fmt[${i}]}" "${cow_img[${i}]}"
        [[ $? ]] && return $?
      else
        echo "[touch_cow[$i]] Found COW image ${cow_img[${i}]}"
      fi
    elif [[ -n ${base_img[${i}]} && -n ${base_fmt[${i}]} ]]; then
      if [[ ! -e ${base_img[${i}]} ]]; then
        local _base_cap=${base_cap[${i}]:-8G}
        qemu-img create -f "${base_fmt[${i}]}" "${base_img[${i}]}" ${_base_cap}
        [[ $? ]] && return $?
      fi
    fi
  done
}

gen_sys()
{
  local _qemu_binary=${qemu_binary:-qemu-system-x86_64}
  echo ${_qemu_binary} -nodefaults $(gen_display) $(gen_cpu_memory) $(gen_serial) $(gen_monitor) $(gen_bridge) $(gen_cdrom) $(gen_disks) $(gen_boot)
}

run_sys()
{
  touch_imgs
  if [[ $? != 0 ]]; then
    echo "touch_cow failed!"
    return $?
  fi
  # need special treatment for append. SHIT!
  if [[ -n "${kernel}" && -n "${initrd}" && -n "${append}" ]]; then
    $(gen_sys) -kernel "${kernel}" -initrd "${initrd}" -append "${append}"
  else
    $(gen_sys)
  fi
}

$dowhat
