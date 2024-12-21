# docker

[Docker static binary](https://download.docker.com/linux/static/stable/)

[CNI plugins](https://github.com/containernetworking/plugins)
```
install -v -m 0755 -d /opt/cni/bin
tar -xof cni-plugins-linux-amd64-v1.6.1.tgz
rm -vfr LICENSE README.md
install -v -c -m 0755 -d /opt/cni/bin/

```

