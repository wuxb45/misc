#!/bin/bash

mac=$(ip link show eth0 | grep 'link/ether' | awk '{print $2}')
if [[ -z ${mac} ]]; then
  exit 1
fi

log=/tmp/auto-ip.log

echo macaddr: $mac >> $log

if [[ ! ${mac} =~ 52:54:00:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F]:[0-9a-fA-F][0-9a-fA-F] ]]; then
  echo "ip not set, exit" >> $log
  exit 1
fi

eth0start()
{
  # set ip
  local suf4=$(echo ${mac} | awk -F: '{print $4}')
  local suf5=$(echo ${mac} | awk -F: '{print $5}')
  local suf6=$(echo ${mac} | awk -F: '{print $6}')
  local ipaddr=$(printf '10.%d.%d.%d' 0x${suf4} 0x${suf5} 0x${suf6})
  local hostname="v${suf4}${suf5}${suf6}"
  echo ipaddr: $ipaddr >> $log
  ip addr add ${ipaddr}/8 dev eth0
  ip link set eth0 up
  ip route add default via 10.0.0.1 dev eth0
  echo "nameserver 8.8.8.8" > /etc/resolv.conf
  echo "nameserver 8.8.4.4" >> /etc/resolv.conf
  hostname ${hostname}
}

eth0stop()
{
  echo "stopped" >> $log
  ip addr flush dev eth0
  ip route flush dev eth0
  ip link set dev eth0 down
}

if [[ $1 == start ]]; then
  eth0start
elif [[ $1 == stop ]]; then
  eth0stop
else
  exit 1
fi
