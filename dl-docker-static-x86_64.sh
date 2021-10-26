#!/usr/bin/env bash
export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
TZ='UTC'; export TZ

set -e

_tmp_dir="$(mktemp -d)"
cd "${_tmp_dir}"
mkdir static re-pack compose rootless-extras buildx
rm -fr /tmp/docker*.tar*

cd static
_filename="$(wget -qO- 'https://download.docker.com/linux/static/stable/x86_64/' | grep '<a href="' | sed -e '/extras/d' | grep 'tgz"' | cut -d'"' -f2 | grep 'tgz$' | sort -V | uniq | tail -n 1)"
_version="$(echo "${_filename}" | sed 's/\.tgz$//g' | cut -d- -f2)"
echo "${_version}"
wget -c -t 0 -T 9 "https://download.docker.com/linux/static/stable/x86_64/${_filename}"
sleep 2
tar -xf "${_filename}"
sleep 2
rm -f "${_filename}"

cd ../rootless-extras
wget -c -t 0 -T 9 "https://download.docker.com/linux/static/stable/x86_64/docker-rootless-extras-${_version}.tgz"
sleep 2
tar -xf "docker-rootless-extras-${_version}.tgz"
sleep 2
rm -f "docker-rootless-extras-${_version}.tgz"

cd ../compose
_compose_version="$(wget -qO- 'https://github.com/docker/compose/releases/' | grep -i '<a href="/docker/compose/tree/' | sed 's/ /\n/g' | grep -i '^href="/docker/compose/tree/' | sed 's@href="/docker/compose/tree/@@g' | sed 's/"//g' | grep -ivE 'alpha|beta|rc' | sort -V | uniq | tail -1)"
_compose_file="$(wget -qO- 'https://github.com/docker/compose/releases/' | grep -i 'docker-compose-linux-x86_64' | grep -i "${_compose_version}" | grep -iv '\.sha' | sed 's|"|\n|g' | grep -i '^/docker/compose/releases/download/' | awk -F/ '{print $NF}' | tail -n 1)"
wget -c -t 0 -T 9 "https://github.com/docker/compose/releases/download/${_compose_version}/${_compose_file}.sha256"
wget -c -t 0 -T 9 "https://github.com/docker/compose/releases/download/${_compose_version}/${_compose_file}"
echo
sleep 2
sha256sum -c "${_compose_file}.sha256"
rc=$?
if [[ $rc != 0 ]]; then
    exit 1
fi
sleep 2
rm -f *.sha*
echo
mv -f "${_compose_file}" docker-compose
echo

cd ../buildx
_buildx_ver="$(wget -qO- 'https://github.com/docker/buildx/releases' | grep -i 'a href="/docker/buildx/releases/download/' | sed 's|"|\n|g' | grep -i '^/docker/buildx/releases/download/.*linux-amd64.*' | grep -ivE 'alpha|beta|rc[0-9]' | sed -e 's|.*/buildx-v||g' -e 's|\.linux.*||g' | sort -V | uniq | tail -n 1)"
wget -c -t 0 -T 9 "https://github.com/docker/buildx/releases/download/v${_buildx_ver}/buildx-v${_buildx_ver}.linux-amd64"
sleep 2
mv -f "buildx-v${_buildx_ver}.linux-amd64" docker-buildx
sleep 2
chmod 0755 docker-buildx

cd ../re-pack

install -m 0755 -d usr/bin
install -m 0755 -d usr/libexec/docker/cli-plugins
#install -m 0755 -d usr/lib/systemd/system
install -m 0755 -d etc/containerd
install -m 0755 -d etc/docker
install -m 0755 -d var/lib/docker
install -m 0755 -d var/lib/docker-engine
install -m 0755 -d var/lib/containerd

install -m 0755 -d etc/systemd/system/docker.service.d

install -v -c -m 0755 ../static/docker/* usr/bin/
install -v -c -m 0755 ../rootless-extras/docker-rootless-extras/* usr/bin/
#install -v -c -m 0755 ../compose/docker-compose usr/bin/
install -v -c -m 0755 ../compose/docker-compose usr/libexec/docker/cli-plugins/
install -v -c -m 0755 ../buildx/docker-buildx usr/libexec/docker/cli-plugins/

###############################################################################

printf '\x23\x20\x20\x20\x43\x6F\x70\x79\x72\x69\x67\x68\x74\x20\x32\x30\x31\x38\x2D\x32\x30\x32\x30\x20\x44\x6F\x63\x6B\x65\x72\x20\x49\x6E\x63\x2E\x0A\x0A\x23\x20\x20\x20\x4C\x69\x63\x65\x6E\x73\x65\x64\x20\x75\x6E\x64\x65\x72\x20\x74\x68\x65\x20\x41\x70\x61\x63\x68\x65\x20\x4C\x69\x63\x65\x6E\x73\x65\x2C\x20\x56\x65\x72\x73\x69\x6F\x6E\x20\x32\x2E\x30\x20\x28\x74\x68\x65\x20\x22\x4C\x69\x63\x65\x6E\x73\x65\x22\x29\x3B\x0A\x23\x20\x20\x20\x79\x6F\x75\x20\x6D\x61\x79\x20\x6E\x6F\x74\x20\x75\x73\x65\x20\x74\x68\x69\x73\x20\x66\x69\x6C\x65\x20\x65\x78\x63\x65\x70\x74\x20\x69\x6E\x20\x63\x6F\x6D\x70\x6C\x69\x61\x6E\x63\x65\x20\x77\x69\x74\x68\x20\x74\x68\x65\x20\x4C\x69\x63\x65\x6E\x73\x65\x2E\x0A\x23\x20\x20\x20\x59\x6F\x75\x20\x6D\x61\x79\x20\x6F\x62\x74\x61\x69\x6E\x20\x61\x20\x63\x6F\x70\x79\x20\x6F\x66\x20\x74\x68\x65\x20\x4C\x69\x63\x65\x6E\x73\x65\x20\x61\x74\x0A\x0A\x23\x20\x20\x20\x20\x20\x20\x20\x68\x74\x74\x70\x3A\x2F\x2F\x77\x77\x77\x2E\x61\x70\x61\x63\x68\x65\x2E\x6F\x72\x67\x2F\x6C\x69\x63\x65\x6E\x73\x65\x73\x2F\x4C\x49\x43\x45\x4E\x53\x45\x2D\x32\x2E\x30\x0A\x0A\x23\x20\x20\x20\x55\x6E\x6C\x65\x73\x73\x20\x72\x65\x71\x75\x69\x72\x65\x64\x20\x62\x79\x20\x61\x70\x70\x6C\x69\x63\x61\x62\x6C\x65\x20\x6C\x61\x77\x20\x6F\x72\x20\x61\x67\x72\x65\x65\x64\x20\x74\x6F\x20\x69\x6E\x20\x77\x72\x69\x74\x69\x6E\x67\x2C\x20\x73\x6F\x66\x74\x77\x61\x72\x65\x0A\x23\x20\x20\x20\x64\x69\x73\x74\x72\x69\x62\x75\x74\x65\x64\x20\x75\x6E\x64\x65\x72\x20\x74\x68\x65\x20\x4C\x69\x63\x65\x6E\x73\x65\x20\x69\x73\x20\x64\x69\x73\x74\x72\x69\x62\x75\x74\x65\x64\x20\x6F\x6E\x20\x61\x6E\x20\x22\x41\x53\x20\x49\x53\x22\x20\x42\x41\x53\x49\x53\x2C\x0A\x23\x20\x20\x20\x57\x49\x54\x48\x4F\x55\x54\x20\x57\x41\x52\x52\x41\x4E\x54\x49\x45\x53\x20\x4F\x52\x20\x43\x4F\x4E\x44\x49\x54\x49\x4F\x4E\x53\x20\x4F\x46\x20\x41\x4E\x59\x20\x4B\x49\x4E\x44\x2C\x20\x65\x69\x74\x68\x65\x72\x20\x65\x78\x70\x72\x65\x73\x73\x20\x6F\x72\x20\x69\x6D\x70\x6C\x69\x65\x64\x2E\x0A\x23\x20\x20\x20\x53\x65\x65\x20\x74\x68\x65\x20\x4C\x69\x63\x65\x6E\x73\x65\x20\x66\x6F\x72\x20\x74\x68\x65\x20\x73\x70\x65\x63\x69\x66\x69\x63\x20\x6C\x61\x6E\x67\x75\x61\x67\x65\x20\x67\x6F\x76\x65\x72\x6E\x69\x6E\x67\x20\x70\x65\x72\x6D\x69\x73\x73\x69\x6F\x6E\x73\x20\x61\x6E\x64\x0A\x23\x20\x20\x20\x6C\x69\x6D\x69\x74\x61\x74\x69\x6F\x6E\x73\x20\x75\x6E\x64\x65\x72\x20\x74\x68\x65\x20\x4C\x69\x63\x65\x6E\x73\x65\x2E\x0A\x0A\x64\x69\x73\x61\x62\x6C\x65\x64\x5F\x70\x6C\x75\x67\x69\x6E\x73\x20\x3D\x20\x5B\x22\x63\x72\x69\x22\x5D\x0A\x0A\x23\x72\x6F\x6F\x74\x20\x3D\x20\x22\x2F\x76\x61\x72\x2F\x6C\x69\x62\x2F\x63\x6F\x6E\x74\x61\x69\x6E\x65\x72\x64\x22\x0A\x23\x73\x74\x61\x74\x65\x20\x3D\x20\x22\x2F\x72\x75\x6E\x2F\x63\x6F\x6E\x74\x61\x69\x6E\x65\x72\x64\x22\x0A\x23\x73\x75\x62\x72\x65\x61\x70\x65\x72\x20\x3D\x20\x74\x72\x75\x65\x0A\x23\x6F\x6F\x6D\x5F\x73\x63\x6F\x72\x65\x20\x3D\x20\x30\x0A\x0A\x23\x5B\x67\x72\x70\x63\x5D\x0A\x23\x20\x20\x61\x64\x64\x72\x65\x73\x73\x20\x3D\x20\x22\x2F\x72\x75\x6E\x2F\x63\x6F\x6E\x74\x61\x69\x6E\x65\x72\x64\x2F\x63\x6F\x6E\x74\x61\x69\x6E\x65\x72\x64\x2E\x73\x6F\x63\x6B\x22\x0A\x23\x20\x20\x75\x69\x64\x20\x3D\x20\x30\x0A\x23\x20\x20\x67\x69\x64\x20\x3D\x20\x30\x0A\x0A\x23\x5B\x64\x65\x62\x75\x67\x5D\x0A\x23\x20\x20\x61\x64\x64\x72\x65\x73\x73\x20\x3D\x20\x22\x2F\x72\x75\x6E\x2F\x63\x6F\x6E\x74\x61\x69\x6E\x65\x72\x64\x2F\x64\x65\x62\x75\x67\x2E\x73\x6F\x63\x6B\x22\x0A\x23\x20\x20\x75\x69\x64\x20\x3D\x20\x30\x0A\x23\x20\x20\x67\x69\x64\x20\x3D\x20\x30\x0A\x23\x20\x20\x6C\x65\x76\x65\x6C\x20\x3D\x20\x22\x69\x6E\x66\x6F\x22\x0A' | dd seek=$((0x0)) conv=notrunc bs=1 of=etc/containerd/config.toml
sleep 1
chmod 0644 etc/containerd/config.toml

printf '\x7B\x22\x70\x6C\x61\x74\x66\x6F\x72\x6D\x22\x3A\x22\x44\x6F\x63\x6B\x65\x72\x20\x45\x6E\x67\x69\x6E\x65\x20\x2D\x20\x43\x6F\x6D\x6D\x75\x6E\x69\x74\x79\x22\x2C\x22\x65\x6E\x67\x69\x6E\x65\x5F\x69\x6D\x61\x67\x65\x22\x3A\x22\x65\x6E\x67\x69\x6E\x65\x2D\x63\x6F\x6D\x6D\x75\x6E\x69\x74\x79\x2D\x64\x6D\x22\x2C\x22\x63\x6F\x6E\x74\x61\x69\x6E\x65\x72\x64\x5F\x6D\x69\x6E\x5F\x76\x65\x72\x73\x69\x6F\x6E\x22\x3A\x22\x31\x2E\x32\x2E\x30\x2D\x62\x65\x74\x61\x2E\x31\x22\x2C\x22\x72\x75\x6E\x74\x69\x6D\x65\x22\x3A\x22\x68\x6F\x73\x74\x5F\x69\x6E\x73\x74\x61\x6C\x6C\x22\x7D\x0A' | dd seek=$((0x0)) conv=notrunc bs=1 of=var/lib/docker-engine/distribution_based_engine.json
sleep 1
chmod 0644 var/lib/docker-engine/distribution_based_engine.json

echo '[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target' > etc/docker/docker.service
sleep 1
chmod 0644 etc/docker/docker.service

echo '[Unit]
Description=Docker Socket for the API
PartOf=docker.service

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
SocketGroup=docker

[Install]
WantedBy=sockets.target' > etc/docker/docker.socket
sleep 1
chmod 0644 etc/docker/docker.socket

echo '#   Copyright 2018-2020 Docker Inc.

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at

#       https://www.apache.org/licenses/LICENSE-2.0

#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=-/sbin/modprobe overlay
ExecStart=/usr/bin/containerd
KillMode=process
Delegate=yes
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity
TasksMax=infinity

[Install]
WantedBy=multi-user.target' > etc/docker/containerd.service
sleep 1
chmod 0644 etc/docker/containerd.service

echo '{
  "dns": [
    "8.8.8.8"
  ]
}' > etc/docker/daemon.json
sleep 1
chmod 0644 etc/docker/daemon.json

echo '
rm -f /lib/systemd/system/containerd.service
rm -f /lib/systemd/system/docker.service
rm -f /lib/systemd/system/docker.socket
sleep 1
/bin/systemctl daemon-reload
install -v -c -m 0644 containerd.service /lib/systemd/system/
install -v -c -m 0644 docker.service /lib/systemd/system/
install -v -c -m 0644 docker.socket /lib/systemd/system/
sleep 1
/bin/systemctl daemon-reload > /dev/null 2>&1 || :
getent group docker >/dev/null 2>&1 || groupadd -r docker
' > etc/docker/.install.txt

echo '
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
' > etc/docker/.stop-disable.txt

chmod 0644 etc/docker/.install.txt
chmod 0644 etc/docker/.stop-disable.txt

###############################################################################

echo
sleep 2
file usr/bin/* | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs -I '{}' strip '{}'
file usr/libexec/docker/cli-plugins/* | sed -n -e 's/^\(.*\):[  ]*ELF.*, not stripped.*/\1/p' | xargs -I '{}' strip '{}'

echo
sleep 2
tar -Jcvf /tmp/"docker-${_version}-static-x86_64.tar.xz" *
echo
sleep 2
cd /tmp
sha256sum "docker-${_version}-static-x86_64.tar.xz" > "docker-${_version}-static-x86_64.tar.xz".sha256
sleep 2

cd /tmp
rm -fr "${_tmp_dir}"
echo
echo ' done'
echo
exit

