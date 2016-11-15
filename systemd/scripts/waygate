#!/bin/bash
if [[ -z $1 || -z $2 ]]; then
  echo "usage: $0 <gateport> <outport>"
  exit 0
fi
gateway=$1
outport=$2

ip link show dev ${gateway} &> /dev/null
if [[ $? != 0 ]]; then
  echo "==! Out port not found"
  exit 1
fi
ip link show dev ${outport} &> /dev/null
if [[ $? != 0 ]]; then
  echo "==! Out port not found"
  exit 1
fi

iptables_remove_rule()
{
  iptables -C $* 2>/dev/null
  if [ $? == 0 ]; then
    echo "==> iptables: remove $*"
    iptables -D $*
  else
    echo "==| iptables: not found $*"
  fi
}

# allow br
iptables_remove_rule FORWARD -m physdev --physdev-is-bridged -j ACCEPT

# allow nat in/out
iptables_remove_rule FORWARD -i ${outport} -o ${gateway} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables_remove_rule FORWARD -i ${gateway} -o ${outport} -j ACCEPT

# set NAT
natrule="POSTROUTING -o ${outport} -j MASQUERADE"
iptables -t nat -C ${natrule} 2>/dev/null
if [ $? == 0 ]; then
  echo "==> iptables NAT: remove ${natrule}"
  iptables -t nat -D ${natrule}
else
  echo "==| iptables NAT: not found ${natrule}"
fi
