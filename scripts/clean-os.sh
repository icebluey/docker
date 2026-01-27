#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
apt update -y -qqq
df -Th

apt autoremove --purge -y needrestart || : 
systemctl stop postgresql.service mysql.service mysqld.service >/dev/null 2>&1 || : 
systemctl disable postgresql.service mysql.service mysqld.service >/dev/null 2>&1 || : 
apt autoremove --purge -y '^postgresql.*' '^mysql.*' '^mssql.*' '^msodbcsql.*'
rm -fr /var/lib/postgresql /var/lib/mysql
systemctl stop snapd.service snapd.socket >/dev/null 2>&1 || : 
systemctl disable snapd.service snapd.socket >/dev/null 2>&1 || : 
apt autoremove --purge -y '^php.*' '^lxd.*' '^snap.*'
rm -fr ~/snap /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd /tmp/snap.lxd /tmp/snap-private-tmp
systemctl stop docker.service containerd.service >/dev/null 2>&1 || : 
systemctl disable docker.service containerd.service >/dev/null 2>&1 || : 
apt autoremove --purge -y '^docker.*' '^container.*' '^podman.*' crun runc
rm -fr /var/lib/docker* /var/lib/containerd /usr/libexec/docker /etc/docker /etc/containerd
apt autoremove --purge -y --allow-remove-essential '^firefox.*' '^firebird.*' '^google.*' '^dotnet.*' '^microsoft.*' '^mono-.*' '^powershell.*' '^llvm.*'

systemctl stop systemd-resolved.service
systemctl stop systemd-timesyncd
systemctl stop unattended-upgrades
systemctl stop udisks2.service
systemctl disable systemd-resolved.service
systemctl disable systemd-timesyncd
systemctl disable unattended-upgrades
systemctl disable udisks2.service

rm -fr /etc/resolv.conf
echo "nameserver 8.8.8.8" >/etc/resolv.conf 

apt install -y chrony
systemctl stop chrony.service
sed -e "/^pool/d" -i /etc/chrony/chrony.conf
sed -e "/^server/d" -i /etc/chrony/chrony.conf
sed -e "s|^refclock|#refclock|g" -i /etc/chrony/chrony.conf
sed -e "1iserver time1.google.com iburst minpoll 4 maxpoll 5\nserver time2.google.com iburst minpoll 4 maxpoll 5\nserver time3.google.com iburst minpoll 4 maxpoll 5\nserver time4.google.com iburst minpoll 4 maxpoll 5" -i /etc/chrony/chrony.conf
systemctl start chrony.service
systemctl enable chrony.service
sleep 10
chronyc makestep

#apt install -y binutils coreutils util-linux findutils diffutils sed gawk grep file tar gzip bzip2 xz-utils
#apt install -y make gcc g++ m4 pkg-config perl libperl-dev groff-base dpkg-dev cmake
#apt install -y autoconf autoconf-archive autogen automake autopoint autotools-dev libtool m4 bison flex
#apt install -y libseccomp-dev libseccomp2 gperf

df -Th
exit
