##Update the OS
echo "[TASK 3] Update yum packages"
yum update -y

echo "[TASK 4] Installation of git bash-completion"
## Install yum-utils, bash completion, git, and more
yum install yum-utils nfs-utils bash-completion git -y
yum install epel-release yum-utils device-mapper-persistent-data lvm2 wget -y
yum install curl jq tar -y
yum install perl perl-Digest-SHA -y


echo "[TASK 5] Disable firewalld"
##Disable firewall starting from Kubernetes v1.19 onwards
systemctl stop firewalld
systemctl disable firewalld --now
systemctl mask --now firewalld
systemctl status -l firewalld

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
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
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
cp -vf /etc/fstab /etc/fstab.bak

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
#OS=CentOS_7
export OS=CentOS_8_Stream

echo "[TASK 18] Set CRI-O"
#set CRI-O
#export VERSION=1.23:1.23.2
#export OS=CentOS_8_Stream
#export OS=CentOS_8_Stream
#export VERSION=1.25:1.25.0
#export OS=CentOS_8_Stream
export VERSION=1.24:1.24.0
#curl https://raw.githubusercontent.com/cri-o/cri-o/main/scripts/get | bash -s -- -t v1.24.0


echo "[TASK 19] Install CRI-O"
#Install CRI-O
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/devel:kubic:libcontainers:stable.repo
curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo
curl https://raw.githubusercontent.com/cri-o/cri-o/main/scripts/get | bash -s -- -t v1.24.0
yum clean packages
yum install cri-o -y --disablerepo=kubernetes
yum install -y containernetworking-plugins

echo "[TASK 20] Install Kubernetes, specify Version as CRI-O"
##Install Kubernetes, specify Version as CRI-O
#yum install -y kubelet-1.23.2-0 kubeadm-1.23.2-0 kubectl-1.23.2-0 --disableexcludes=kubernetes
yum install -y kubelet-1.24.0-0 kubeadm-1.24.0-0 kubectl-1.24.0-0 --disableexcludes=kubernetes


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

echo "[TASK 25] Ensure to start kubernetes cluster with v1.24.0"
kubeadm init  --pod-network-cidr=10.244.0.0/16 --kubernetes-version=v1.24.0 --ignore-preflight-errors all

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
kubectl taint nodes --all node-role.kubernetes.io/control-plane-

echo "[TASK 36] Install kubectl convert plugin"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert"

echo "[TASK 37] Install kubectl convert sha"
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl-convert.sha256"

echo "[TASK 38] verify kubectl convert plugin"
echo "$(cat kubectl-convert.sha256) kubectl-convert" | sha256sum --check

echo "[TASK 39] install kubectl convert to linux binary"
sudo install -o root -g root -m 0755 kubectl-convert /usr/local/bin/kubectl-convert

echo "[TASK 40] kubectl convert verify"
kubectl convert --help

echo "[TASK 41] create namespace metallb-system"
kubectl create namespace metallb-system

echo "[TASK 42] install bare-metal-lb-config"
cp -v /vagrant/metal-lb-config.yaml metal-lb-config.yaml
kubectl create -f metal-lb-config.yaml

echo "[TASK 43] configure kubeadm"
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
sudo chmod 755 /etc/kubernetes/admin.conf
