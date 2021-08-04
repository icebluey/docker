#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

/bin/systemctl daemon-reload
sleep 1

systemctl stop docker > /dev/null 2>&1 || :
systemctl stop containerd.service > /dev/null 2>&1 || :

systemctl disable docker > /dev/null 2>&1 || :
systemctl disable containerd.service > /dev/null 2>&1 || :

ip link set docker0 down 2>/dev/null || : 

exit

