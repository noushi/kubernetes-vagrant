





# Setup

## Requirements

- Virtualbox or libvirt (kvm)
- Vagrant
- openssh-sftp-server

## Host Setup

You may need to change the value of the `BRIDGE` envvar depending on your actual setup


# Steps

## Creating the environment

1. `vagrant up` (or `vagrant up --provider=$YOUR_PREFERRED_PROVIDER`)
1. have a coffee


## Installing Kubernetes (with Calico)

1. `vagrang ssh` (will get you to the `control` VM)

1. run ansible playbooks
 ```
cd src/ansible`
ansible-playbook apt.yml
ansible-playbook base.yml
ansible-playbook no-swap.yml
ansible-playbook master.yml
ansible-playbook node.yml
ansible-playbook control.yml
 ```
### Using a specific Kubernetes control plane version

Replace 
```
ansible-playbook master.yml
```
with 
```
ansible-playbook master.yml -e k8s_extra_opts="--kubernetes-version=v1.19.2"
```


# Misc

## aliases

in the `control` VM, these aliases will prove useful:
```
echo "alias each='ansible -e ansible_become=yes all -a'"  
echo "alias keach='ansible -e ansible_become=yes k8s -a'" 
```


## reset cluster

- keep an eye on non master nodes
 ```
watch -n1 kubectl get node -l "'kubernetes.io/hostname != master'"
 ```

- reset non master nodes then the master
 ```
keach 'kubeadm -f reset' --limit k8s-nodes
k delete node -l kubernetes.io/hostname=master-
 ```

- reset netfilter tables
 ```
keach 'sh -c "iptables -P INPUT ACCEPT ; iptables -P FORWARD ACCEPT ; iptables -P OUTPUT ACCEPT ; iptables -t nat -F ; iptables -t mangle -F ; iptables -F ; iptables -X"'
 ```

- check netfilter tables status
 ```
keach 'iptables -vnL'
 ```

