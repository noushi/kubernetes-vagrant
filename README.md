


```bash
BRIDGE=vboxnet2 # vbox
#BRIDGE=virbr3 # libvirt
PORTS="111 2049 13025 "
for i in $PORTS ; do
	ufw allow in on $BRIDGE to any port $i
done
```
