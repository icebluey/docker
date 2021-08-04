#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

/bin/systemctl daemon-reload
sleep 2
systemctl stop docker >/dev/null 2>&1 || :
systemctl stop containerd.service >/dev/null 2>&1 || :

systemctl disable docker >/dev/null 2>&1 || :
systemctl disable containerd.service >/dev/null 2>&1 || :

set -e

rm -f /usr/bin/containerd
rm -f /usr/bin/containerd-shim
rm -f /usr/bin/containerd-shim-runc-v2
rm -f /usr/bin/ctr
rm -f /usr/bin/docker
rm -f /usr/bin/dockerd
rm -f /usr/bin/dockerd-rootless-setuptool.sh
rm -f /usr/bin/dockerd-rootless.sh
rm -f /usr/bin/docker-init
rm -f /usr/bin/docker-proxy
rm -f /usr/bin/rootlesskit
rm -f /usr/bin/rootlesskit-docker-proxy
rm -f /usr/bin/runc
rm -f /usr/bin/vpnkit

rm -f /usr/bin/docker-compose

rm -fr /usr/lib/systemd/system/containerd.service
rm -fr /usr/lib/systemd/system/docker.service
rm -fr /usr/lib/systemd/system/docker.socket

rm -fr /lib/systemd/system/containerd.service
rm -fr /lib/systemd/system/docker.service
rm -fr /lib/systemd/system/docker.socket

rm -fr /var/lib/docker-engine
rm -fr /var/lib/docker
rm -fr /var/run/containerd
rm -fr /var/run/docker
rm -fr /run/containerd
rm -fr /run/docker
rm -fr /etc/containerd
rm -fr /etc/docker

rm -fr /etc/systemd/system/docker.service.d

userdel -f -r docker 2>/dev/null || :
groupdel -f docker 2>/dev/null || :

ip link set docker0 down 2>/dev/null

/bin/systemctl daemon-reload

exit
