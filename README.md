# docker

[Docker static binary](https://download.docker.com/linux/static/stable/)

[CNI plugins](https://github.com/containernetworking/plugins)
```
install -v -m 0755 -d /opt/cni/bin
tar -xof cni-plugins-linux-amd64-v1.6.1.tgz
rm -vfr LICENSE README.md
install -v -c -m 0755 -d /opt/cni/bin/

```

/etc/modules-load.d/k8s.conf 
```
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
