#!/bin/bash
if [[ $(whoami) != 'root' ]]; then
  echo "==! need root to execute"
  exit 0
fi

check_cmd ()
{
  if [[ -z $(which $1) ]]; then
    echo No $1
    exit 0
  fi
}

check_cmd brctl
check_cmd sysctl
check_cmd iptables

outport=$1
if [[ -z ${outport} ]]; then
  echo "usage: $0 <out-port>"
  exit 0
fi

ip link show dev ${outport} &> /dev/null
if [ $? != 0 ]; then
  echo "==! Out port not found"
  exit 0
fi

brname="nat@${outport}"

#### set allow br in /etc/qemu/bridge.conf
qbrconf="/etc/qemu/bridge.conf"
if [[ ! -e ${qbrconf} ]]; then
  echo "==> ${qbrconf} Set allow ${brname}"
  echo "allow ${brname}" > ${qbrconf}
elif [[ -z $(grep "^allow ${brname}"'$' ${qbrconf}) ]]; then
  echo "==> ${qbrconf} Add allow ${brname}"
  echo "allow ${brname}" >> ${qbrconf}
else
  echo "==| found ${qbrconf} allow ${brname}"
fi


if [[ ! $(sysctl net.ipv4.ip_forward | egrep '.*=.*1$') ]]; then
  echo "==> set ip_forward = 1"
  sysctl net.ipv4.ip_forward=1
else
  echo "==| found ip_forward = 1"
fi

if [[ -z $(brctl show | grep "^${brname}") ]]; then
  echo "==> add ${brname}"
  brctl addbr "${brname}"
else
  echo "==| found ${brname}"
fi

if [[ -z $(ip addr show dev ${brname} | grep '10\.0\.0\.1/8') ]]; then
  echo "==> assign 10.0.0.1/8 to ${brname}"
  ip addr add 10.0.0.1/8 dev ${brname}
  ip link set dev ${brname} up
else
  echo "==| found ${brname} ip"
fi

echo "configure NAT to ${outport}"

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

# allow br
iptables_put_rule FORWARD -m physdev --physdev-is-bridged -j ACCEPT

# allow nat in/out
iptables_put_rule FORWARD -i ${outport} -o ${brname} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables_put_rule FORWARD -i ${brname} -o ${outport} -j ACCEPT

# set NAT
natrule="POSTROUTING -o ${outport} -j MASQUERADE"
iptables -t nat -C ${natrule} 2>/dev/null
if [ $? != 0 ]; then
  echo "==> iptables NAT: set ${natrule}"
  iptables -t nat -A ${natrule}
else
  echo "==| iptables NAT: found ${natrule}"
fi
