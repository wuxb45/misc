#!/bin/bash
MIROOT=/home/http/mirror

echo "==start: $(date)" >>/tmp/rsyncdo.log
syncdir()
{
  # $1 host $2 dir
  local remote="rsync://${MRSITE}/${RPREFIX}${MRDIR}/"
  local localdir="${MIROOT}/${LPREFIX}${MRDIR}"
  mkdir -p ${localdir}
  echo "SYNCDIR $@ ${remote} ${localdir}"
  rsync -qrtLH --no-motd --delete-after --ignore-errors --timeout=10 --chown=http:http "$@" ${remote} ${localdir}
}

## archlinux
# https://www.archlinux.org/mirrors/status/
LPREFIX="archlinux"
RPREFIX="archlinux"
mirrors=("mirror.us.leaseweb.net" "mirrors.kernel.org")
MRSITE=${mirrors[$(($RANDOM % 2))]}
MRDIR="/core/os/x86_64"
syncdir
MRDIR="/extra/os/x86_64"
syncdir
MRDIR="/community/os/x86_64"
syncdir
MRDIR="/multilib/os/x86_64"
syncdir
MRDIR="/iso/latest"
syncdir

## centos
# http://www.centos.org/download/mirrors/
LPREFIX="centos"
RPREFIX="centos"
MRDIR="/5/isos/x86_64"
syncdir
MRDIR="/6/isos/x86_64"
syncdir
MRDIR="/7/isos/x86_64"
syncdir

## linux kernel
LPREFIX="kernel"
RPREFIX="kernel"
mirrors=("mirror.us.leaseweb.net" "rsync.kernel.org/pub/linux")
MRSITE=${mirrors[$(($RANDOM % 2))]}
MRDIR="/v3.x"
syncdir --exclude '*.sign' --include 'linux-*.tar.xz' --include 'ChangeLog-*' --include 'patch-*.xz' --exclude '*'
MRDIR="/v4.x"
syncdir --exclude '*.sign' --include 'linux-*.tar.xz' --include 'ChangeLog-*' --include 'patch-*.xz' --exclude '*'

## apache
LPREFIX="apache"
RPREFIX="apache-dist"
MRSITE="apache.cs.utah.edu"
MRDIR=""
syncdir

## finish
date > $MIROOT/lastsync
echo "==done:  $(date)" >>/tmp/rsyncdo.log
