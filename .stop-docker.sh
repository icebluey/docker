#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

/bin/systemctl daemon-reload > /dev/null 2>&1 || :
sleep 1
systemctl stop docker.socket > /dev/null 2>&1 || :
systemctl stop docker.service > /dev/null 2>&1 || :
systemctl stop containerd.service > /dev/null 2>&1 || :
systemctl disable docker.socket > /dev/null 2>&1 || :
systemctl disable docker.service > /dev/null 2>&1 || :
systemctl disable containerd.service > /dev/null 2>&1 || :
ip link set docker0 down > /dev/null 2>&1 || :

rm -fr /run/containerd
rm -fr /run/docker.sock
rm -fr /run/docker
rm -fr /var/run/containerd
rm -fr /var/run/docker.sock
rm -fr /var/run/docker

exit

