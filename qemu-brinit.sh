#!/bin/bash
if [[ $(whoami) != 'root' ]]; then
  echo "==! need root to execute"
  exit 0
fi

fail=
check_cmd ()
{
  if [[ -z $(which $1) ]]; then
    echo No $1
    fail=1
  fi
}

#### set allow br0 in /etc/qemu/bridge.conf
qbrconf="/etc/qemu/bridge.conf"
if [[ ! -e ${qbrconf} ]]; then
  echo "==> qemu Set allow br0"
  echo 'allow br0' > ${qbrconf}
elif [[ -z $(grep '^allow br0$' ${qbrconf}) ]]; then
  echo "==> qemu Add allow br0"
  echo 'allow br0' >> ${qbrconf}
else
  echo "==| qemu allow br0 already set"
fi

check_cmd brctl
check_cmd sysctl
check_cmd iptables

if [[ $fail ]]; then
  exit 0
fi

if [[ ! $(sysctl net.ipv4.ip_forward | egrep '.*=.*1$') ]]; then
  echo "==> set ip_forward"
  sysctl net.ipv4.ip_forward=1
else
  echo "==| ip_forward already set"
fi

if [[ -z $(brctl show | grep '^br0') ]]; then
  echo "==> add br0"
  brctl addbr br0
else
  echo "==| br0 exists"
fi

if [[ -z $(iptables --list | egrep '^ACCEPT.*PHYSDEV.*--physdev-is-bridged') ]]; then
  echo "==> add iptables rule"
  iptables -I FORWARD -m physdev --physdev-is-bridged -j ACCEPT
else
  echo "==| iptables rule exists"
fi
