#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hemanth\nhemanth" | passwd root >/dev/null 2>&1

##Update the OS
echo "[TASK 3] Update yum packages"
yum update -y

echo "[TASK 4] Installation of git bash-completion"
## Install yum-utils, bash completion, git, and more
yum install yum-utils nfs-utils bash-completion git -y

echo "[TASK 5] Disable firewalld"
##Disable firewall starting from Kubernetes v1.19 onwards
systemctl disable firewalld --now

echo "[TASK 6] Letting ipTables see bridged networks"
## letting ipTables see bridged networks
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

echo "[TASK 7] Letting ipTables6 see bridged networks"
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
 
echo "[TASK 8] Iptables config as specified by CRI-O documentation"
##
## iptables config as specified by CRI-O documentation
# Create the .conf file to load the modules at bootup
cat <<EOF | sudo tee /etc/modules-load.d/crio.conf
overlay
br_netfilter
EOF
 
echo "[TASK 9] Compiling overlay and br_netfilter kernel modules"
modprobe overlay
modprobe br_netfilter
 
echo "[TASK 10] Set up required sysctl params, these persist across reboots"
# Set up required sysctl params, these persist across reboots.
cat <<EOF | sudo tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF
sysctl --system

echo "[TASK 11] Configuring Kubernetes repositories"
###
## configuring Kubernetes repositories
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

echo "[TASK 12] Set SELinux in permissive mode"
## Set SELinux in permissive mode (effectively disabling it)
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

echo "[TASK 13] Disable swap"
### Disable swap
swapoff -a

echo "[TASK 14] Make a backup of fstab"
##make a backup of fstab
cp -f /etc/fstab /etc/fstab.bak

echo "[TASK 15] Remove swap from fstab"
##Renove swap from fstab
sed -i '/swap/d' /etc/fstab
 
echo "[TASK 16] Refresh repo list"
##Refresh repo list
yum repolist -y

## Install CRI-O binaries
##########################
 
#Operating system   $OS
#Centos 8   CentOS_8
#Centos 8 Stream    CentOS_8_Stream
#Centos 7   CentOS_7

echo "[TASK 17] Set OS version"
#set OS version
OS=CentOS_7
export OS=CentOS_7

echo "[TASK 18] Set CRI-O"
#set CRI-O
VERSION=1.20
export OS=CentOS_7

echo "[TASK 19] Install CRI-O"
#Install CRI-O
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo
yum install cri-o -y

echo "[TASK 20] Install Kubernetes, specify Version as CRI-O"
##Install Kubernetes, specify Version as CRI-O
yum install -y kubelet-1.20.0-0 kubeadm-1.20.0-0 kubectl-1.20.0-0 --disableexcludes=kubernetes

echo "[TASK 21] Check kubernetes and CRI-O is installed"
rpm -qa | grep kube
rpm -qa | grep cri-o

echo "[TASK 22] Install kubeadm configuration"
cp -f /vagrant/10-kubeadm.conf /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

echo "[TASK 23] Perform daemon-reload"
systemctl daemon-reload

echo "[TASK 24] Ensure to enable CRI-O and kubelet"
systemctl enable crio --now
systemctl enable kubelet --now

echo "[TASK 25] Ensure to start kubernetes cluster with v1.20.10"
kubeadm init  --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.20.10 --ignore-preflight-errors all

echo "[TASK 26] Make kube configuration"
mkdir -p $HOME/.kube

echo "[TASK 27] Create Kube config"
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

echo "[TASK 28] Executing privilages Kube config"
chown $(id -u):$(id -g) $HOME/.kube/config

echo "[TASK 29] Exporting KUBECONFIG"
export KUBECONFIG=/etc/kubernetes/admin.conf

echo "[TASK 30] Summoning KUBECONFIG to .bashrc"
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc

echo "[TASK 31] Pull calico network"
curl https://docs.projectcalico.org/manifests/calico.yaml -O

echo "[TASK 32] Apply calico network"
kubectl apply -f calico.yaml

echo "[TASK 33] Show pods in all namespaces"
kubectl get pod --all-namespaces -o wide

echo "[TASK 34] Show nodes"
kubectl get nodes

echo "[TASK 35] Taint master control plane"
kubectl taint nodes --all node-role.kubernetes.io/master-