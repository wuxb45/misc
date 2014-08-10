#!/bin/bash

username=$1

useradd ${username}
pswd=${RANDOM}
echo !!!set passwd to ${pswd}
echo ${username}:${pswd} | chpasswd


homedir="/home/${username}"
sshdir="${homedir}/.ssh"
key_pri="${sshdir}/id_ecdsa"
key_pub="${key_pri}.pub"
auth="${sshdir}/authorized_keys"
kh="${sshdir}/known_hosts"

mkdir -p ${sshdir}

su - ${username} -c "ssh-keygen -t ecdsa -P '' -f ${key_pri}"

key=$(cat ${key_pub})

cp ${key_pub} ${auth}

echo "localhost ${key}" > ${kh}
for i in $(seq 1 254); do
  echo "v$(printf '%02x' $i),10.10.10.${i} ${key}" >> ${kh}
done

chown -R ${username}:${username} ${homedir}
