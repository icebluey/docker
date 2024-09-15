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
apt autoremove --purge -y $(dpkg -l | grep -i -E 'docker|container' | awk '{print $2}' | sort -V | uniq | paste -sd" ")
/bin/rm -fr /etc/docker /usr/libexec/docker /etc/containerd /var/lib/containerd /var/lib/docker*

# delete mysql postgresql php google-cloud
systemctl disable postgresql.service
systemctl disable mysql.service
systemctl disable mysqld.service
systemctl stop postgresql.service
systemctl stop mysql.service
systemctl stop mysqld.service
apt autoremove --purge -y $(dpkg -l | awk '$2 ~ /mysql|postgresql|google-cloud|^php[1-9]/ {print $2}' |  grep -iv libmysqlclient | sort -V | uniq | paste -sd" ")
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

df -Th
exit
