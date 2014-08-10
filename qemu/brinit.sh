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
  echo "==> ${qbrconf} Set allow br0"
  echo 'allow br0' > ${qbrconf}
elif [[ -z $(grep '^allow br0$' ${qbrconf}) ]]; then
  echo "==> ${qbrconf} Add allow br0"
  echo 'allow br0' >> ${qbrconf}
else
  echo "==| found ${qbrconf} allow br0"
fi

check_cmd brctl
check_cmd sysctl
check_cmd iptables

if [[ $fail ]]; then
  exit 0
fi

if [[ ! $(sysctl net.ipv4.ip_forward | egrep '.*=.*1$') ]]; then
  echo "==> set ip_forward = 1"
  sysctl net.ipv4.ip_forward=1
else
  echo "==| found ip_forward = 1"
fi

if [[ -z $(brctl show | grep '^br0') ]]; then
  echo "==> add br0"
  brctl addbr br0
else
  echo "==| found br0"
fi

if [[ -z $(ip addr show dev br0 | grep '10\.0\.0\.1/8') ]]; then
  echo "==> assign 10.0.0.1/8 to br0"
  ip addr add 10.0.0.1/8 dev br0
  ip link set dev br0 up
else
  echo "==| found br0 ip"
fi

outport=$1
if [ -z ${outport} ]; then
  exit 0
fi

ip link show dev ${outport} &> /dev/null
if [ $? != 0 ]; then
  echo "==! Out port not found, skip NAT"
  exit 0
fi
echo NAT to ${outport}

iptables_put_rule()
{
  iptables -C $* 2>/dev/null
  if [ $? != 0 ]; then
    echo "==> iptables: set $*"
    iptables -I $*
  else
    echo "==| iptables: found $*"
  fi
}

# allow br0
iptables_put_rule FORWARD -m physdev --physdev-is-bridged -j ACCEPT

# allow nat in/out
iptables_put_rule FORWARD -i ${outport} -o br0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables_put_rule FORWARD -i br0 -o ${outport} -j ACCEPT

# set NAT
natrule="POSTROUTING -o ${outport} -j MASQUERADE"
iptables -t nat -C ${natrule} 2>/dev/null
if [ $? != 0 ]; then
  echo "==> iptables NAT: set ${natrule}"
  iptables -t nat -A ${natrule}
else
  echo "==| iptables NAT: found ${natrule}"
fi
