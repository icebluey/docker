# docker

[Docker static binary](https://download.docker.com/linux/static/stable/)

[CNI plugins](https://github.com/containernetworking/plugins)
```
install -v -m 0755 -d /opt/cni/bin
tar -xof cni-plugins-linux-amd64-v1.9.0.tgz
rm -vfr LICENSE README.md
install -v -c -m 0755 -d /opt/cni/bin/

```

/etc/modules-load.d/k8s.conf 
```
nf_conntrack
br_netfilter
ip_vs
nf_conntrack
br_netfilter
ip_vs
ip_vs_rr
ip_vs_wrr
ip_vs_lc
ip_vs_wlc
ip_vs_lblc
ip_vs_lblcr
ip_vs_sh
ip_vs_dh
ip_vs_sed
ip_vs_nq
ip_vs_mh
```

```
# 导出和加载tar镜像文件
docker image save / load

docker image save -o output.tar REPOSITORY:TAG
docker image load -i file.tar
docker image load < file.tar.gz

ls -1 *.tar.gz | xargs --no-run-if-empty -I {} bash -c "docker image load < {}"
ls -1 *.tar | xargs --no-run-if-empty -I {} bash -c "docker image load -i {}"

docker image import 导入镜像没有 REPOSITORY 和 TAG 信息

```
