#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ
apt update -y -qqq
df -Th
/bin/systemctl disable $(/bin/systemctl list-unit-files | grep -i -E 'docker|container|podman' | grep -iv 'container-getty' | awk '{print $1}' | sort -V | uniq | paste -sd" ")
/bin/systemctl stop $(/bin/systemctl list-unit-files | grep -i -E 'docker|container|podman' | grep -iv 'container-getty' | awk '{print $1}' | sort -V | uniq | paste -sd" ")

# delete firefox
apt autoremove --purge -y $(dpkg -l | grep -i -E 'firefox|firebird|google-chrome-stable' | awk '{print $2}' | sort -V | uniq | paste -sd" ")

# delete microsoft
apt autoremove --purge -y $(dpkg -l | grep -i -E 'microsoft|libmono|mono-|monodoc|powershell' | awk '{print $2}' | sort -V | uniq | paste -sd" ")

# delete docker
apt autoremove --purge -y $(dpkg -l | grep -i -E 'docker|container|moby' | awk '{print $2}' | sort -V | uniq | paste -sd" ")
/bin/rm -fr /etc/docker /usr/libexec/docker /etc/containerd /var/lib/containerd /var/lib/docker*

# delete mysql postgresql php google-cloud
systemctl disable postgresql.service
systemctl disable mysql.service
systemctl disable mysqld.service
systemctl stop postgresql.service
systemctl stop mysql.service
systemctl stop mysqld.service
apt autoremove --purge -y $(dpkg -l | awk '$2 ~ /mysql|postgresql|google-cloud|mssql|msbuild|msodbcsql|^llvm-|^php[1-9]/ {print $2}' |  grep -iv libmysqlclient | sort -V | uniq | paste -sd" ")
/bin/rm -fr /var/lib/postgresql /var/lib/mysql

# delete snap
snap remove --purge lxd
snap remove --purge $(snap list | awk 'NR > 1 && $1 !~ /lxd/ && $1 !~ /snapd/ {print $1}' | sort -V | uniq | paste -sd" ")
snap remove --purge lxd
snap remove --purge snapd
_services=(
'snapd.socket'
'snapd.service'
'snapd.apparmor.service'
'snapd.autoimport.service'
'snapd.core-fixup.service'
'snapd.failure.service'
'snapd.recovery-chooser-trigger.service'
'snapd.seeded.service'
'snapd.snap-repair.service'
'snapd.snap-repair.timer'
'snapd.system-shutdown.service'
)
for _service in ${_services[@]}; do
    systemctl stop ${_service} >/dev/null 2>&1
done
sleep 3
for _service in ${_services[@]}; do
    systemctl disable ${_service} >/dev/null 2>&1
done
systemctl disable snapd.service
systemctl disable snapd.socket
systemctl disable snapd.seeded.service
systemctl stop snapd.service
systemctl stop snapd.socket
systemctl stop snapd.seeded.service
apt autoremove --purge lxd-agent-loader snapd
/bin/rm -rf ~/snap
/bin/rm -rf /snap
/bin/rm -rf /var/snap
/bin/rm -rf /var/lib/snapd
/bin/rm -rf /var/cache/snapd
/bin/rm -fr /tmp/snap.lxd
/bin/rm -fr /tmp/snap-private-tmp


/bin/rm -fr /usr/share/sbt
/bin/rm -fr /usr/share/gradle*
/bin/rm -fr /usr/share/miniconda*
/bin/rm -fr /usr/share/az_*
/bin/rm -fr /usr/share/swift*
/bin/rm -fr /usr/share/dotnet*
/bin/rm -fr /usr/lib/snapd
/bin/rm -fr /usr/lib/firefox
/bin/rm -fr /usr/lib/llvm*
/bin/rm -fr /usr/lib/mono
/bin/rm -fr /usr/lib/jvm
/bin/rm -fr /usr/lib/google-cloud-sdk*
/bin/rm -fr /opt/containerd
/bin/rm -fr /opt/mssql-tools
/bin/rm -fr /opt/google
/bin/rm -fr /opt/pipx
/bin/rm -fr /opt/az
/bin/rm -fr /opt/microsoft
/bin/rm -fr /usr/local/sqlpackage
/bin/rm -fr /usr/local/n
/bin/rm -fr /usr/local/aws*
/bin/rm -fr /usr/local/julia*
/bin/rm -fr /usr/local/share
/bin/rm -fr /usr/local/.ghcup
/bin/rm -fr /opt/hostedtoolcache

rm -fr /etc/apt/preferences.d/firefox*
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
apt install -y binutils coreutils util-linux findutils diffutils pkg-config
apt install -y systemd passwd patch sed gawk grep file tar gzip bzip2 xz-utils
apt install -y socat ethtool ipvsadm ipset psmisc bash-completion conntrack iproute2 nfs-common
apt install -y daemon procps net-tools
apt install -y iptables
apt install -y ebtables
apt install -y nftables
apt install -y libseccomp-dev libseccomp2

apt install -y binutils coreutils util-linux findutils diffutils patch sed gawk grep file tar gzip bzip2 xz-utils
apt install -y libc-bin passwd pkg-config groff-base
apt install -y zlib1g-dev libzstd-dev liblzma-dev libbz2-dev tar gzip bzip2 xz-utils
apt install -y libssl-dev openssl procps iproute2 net-tools iputils-ping vim bind9-dnsutils libxml2-utils
apt install -y daemon procps psmisc net-tools
apt install -y lsof strace sysstat tcpdump
apt install -y make gcc g++ perl libperl-dev groff-base dpkg-dev cmake m4
# build from src
apt install -y autoconf autoconf-archive autogen automake autopoint autotools-dev libtool m4 bison flex
# build openssl 1.1.1
apt install -y libsctp-dev
# build nginx
apt install -y bc uuid-dev libgd-dev libxslt1-dev libxml2-dev libpcre2-dev libpcre3-dev libpng-dev libjpeg-dev
# build pinentry (gnupg)
apt install -y libncurses-dev libreadline-dev libldap2-dev libsqlite3-dev libusb-1.0-0-dev libsecret-1-dev
# build openssh
apt install -y libedit-dev libssh2-1-dev libpam0g-dev libsystemd-dev groff-base
# build haproxy
apt install -y libsystemd-dev libcrypt-dev
apt install -y libtinfo-dev libncurses-dev
# run keepalived
apt install -y libnl-3-200 libnl-genl-3-200 libsnmp-dev libnftnl-dev libsystemd0
apt install -y libnftables-dev nftables
apt install -y libipset-dev ipset
apt install -y iptables
apt install -y libsnmp-dev libmnl-dev libnftnl-dev libnl-3-dev libnl-genl-3-dev libnfnetlink-dev
# build nettle for gnutls
apt install -y libgmp-dev
# build gnutls for chrony
apt install -y libp11-kit-dev libidn2-dev
# build chrony
apt install -y libseccomp-dev libcap-dev
# build libfido2
apt install -y libcbor-dev libpcsclite-dev
apt install -y daemon procps psmisc net-tools chrpath libtasn1-6-dev gettext
apt install -y libnftables-dev nftables || : 
apt install -y libipset-dev ipset || : 
apt install -y iptables || : 
apt install -y libsnmp-dev libmnl-dev libnftnl-dev libnl-3-dev libnl-genl-3-dev libnfnetlink-dev || : 

df -Th
exit
