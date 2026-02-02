#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
df -Th

apt update -y -qqq
apt autoremove --purge -y needrestart || : 

systemctl stop snapd.service snapd.socket >/dev/null 2>&1 || : 
systemctl disable snapd.service snapd.socket >/dev/null 2>&1 || : 
systemctl stop postgresql.service mysql.service mysqld.service >/dev/null 2>&1 || : 
systemctl disable postgresql.service mysql.service mysqld.service >/dev/null 2>&1 || : 
systemctl stop docker.service containerd.service >/dev/null 2>&1 || : 
systemctl disable docker.service containerd.service >/dev/null 2>&1 || : 

rm -f /tmp/.installedpackages.tmp.txt
dpkg -l | awk 'NR > 5 && NF >= 2 {print $2}' > /tmp/.installedpackages.tmp.txt
for i in php lxd snap postgresql mysql mssql msodbcsql firefox firebird google dotnet microsoft mono- powershell llvm docker container podman; do
  if grep -q -i "^${i}" /tmp/.installedpackages.tmp.txt; then
    apt autoremove --purge -y --allow-remove-essential "^${i}.*"
  fi
done
rm -f /tmp/.installedpackages.tmp.txt

apt autoremove --purge -y crun runc

rm -fr /var/lib/postgresql /var/lib/mysql
rm -fr ~/snap /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd /tmp/snap.lxd /tmp/snap-private-tmp
rm -fr /var/lib/docker* /var/lib/containerd /usr/libexec/docker /etc/docker /etc/containerd

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

apt install -y wget ca-certificates openssl curl
apt install -y binutils coreutils util-linux findutils diffutils sed gawk grep file tar gzip bzip2 xz-utils
apt install -y util-linux-extra || true

apt install -y chrony
systemctl stop chrony.service
sed 's/^\(pool\|server\|refclock\)/#\1/g' -i /etc/chrony/chrony.conf

sed '1i\
server time1.google.com iburst minpoll 4 maxpoll 5\
server time2.google.com iburst minpoll 4 maxpoll 5\
server time3.google.com iburst minpoll 4 maxpoll 5\
server time4.google.com iburst minpoll 4 maxpoll 5\
server time.apple.com iburst minpoll 4 maxpoll 5\
' -i /etc/chrony/chrony.conf

systemctl start chrony.service
systemctl enable chrony.service
sleep 10
chronyc sources
sleep 10
chronyc sources
sleep 5
chronyc tracking
sleep 2
chronyc makestep
sleep 1
hwclock -w

apt install -y make gcc g++ m4 pkg-config perl libperl-dev groff-base dpkg-dev cmake
apt install -y autoconf autoconf-archive autogen automake autopoint autotools-dev libtool m4 bison flex
apt install -y libseccomp-dev libseccomp2 gperf

df -Th
exit
