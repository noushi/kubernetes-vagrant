





# Setup

## Requirements

- Virtualbox or libvirt (kvm)
- Vagrant

## NFS Host Setup

You may need to change the value of the `BRIDGE` envvar depending on your actual setup

### Virtualbox 

```bash
BRIDGE=vboxnet2
PORTS="111 2049 13025 "
for i in $PORTS ; do
	ufw allow in on $BRIDGE to any port $i
done
```

### Libvirt 

```bash
BRIDGE=virbr3
PORTS="111 2049 13025 "
for i in $PORTS ; do
	ufw allow in on $BRIDGE to any port $i
done
```


# Steps

1. `vagrant up` (or `vagrant up --provider=$YOUR_PREFERRED_PROVIDER`)
1. 



# misc


## reset cluster

```
watch -n1 kubectl get node -l "'kubernetes.io/hostname != master'"
```

```
keach 'kubeadm -f reset' --limit k8s-nodes
k delete node -l kubernetes.io/hostname=master-
```


```
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -F
iptables -X
```

```
keach 'sh -c "iptables -P INPUT ACCEPT ; iptables -P FORWARD ACCEPT ; iptables -P OUTPUT ACCEPT ; iptables -t nat -F ; iptables -t mangle -F ; iptables -F ; iptables -X"'
```

```
keach 'iptables -vnL'
```

