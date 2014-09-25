#!/bin/bash
if [[ -z $1 || -z $2 ]]; then
  echo "Setup a gateway server with a gateway port and an outport."
  echo "usage: $0 <gateport> <outport>"
  exit 0
fi
gateway=$1
outport=$2

ip link show dev ${gateway} &> /dev/null
if [[ $? != 0 ]]; then
  echo "==! Out port not found"
  exit 0
fi
ip link show dev ${outport} &> /dev/null
if [[ $? != 0 ]]; then
  echo "==! Out port not found"
  exit 0
fi

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
iptables_put_rule FORWARD -i ${outport} -o ${gateway} -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables_put_rule FORWARD -i ${gateway} -o ${outport} -j ACCEPT

# set NAT
natrule="POSTROUTING -o ${outport} -j MASQUERADE"
iptables -t nat -C ${natrule} 2>/dev/null
if [ $? != 0 ]; then
  echo "==> iptables NAT: set ${natrule}"
  iptables -t nat -A ${natrule}
else
  echo "==| iptables NAT: found ${natrule}"
fi
