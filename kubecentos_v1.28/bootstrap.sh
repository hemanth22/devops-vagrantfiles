#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hemanth\nhemanth" | passwd root >/dev/null 2>&1

echo "[TASK 3] DNF installation"
dnf update rpm -y
dnf update -y

echo "[TASK 4] Ensure python39 installation"
dnf install python39 -y

echo "[TASK 5] Ensure pip installation"
easy_install-3.9 pip

echo "[TASK 6] Ensure ansible installation"
pip3 install ansible

echo "[TASK 7] Ensure python version updated to 3.9"
alternatives --set python /usr/bin/python3.9

echo "[TASK 8] Ensure to display python version"
python -V
python3 -V
pip3 -V
source ~/.bashrc

echo "[TASK 9] Ensure kubernetes pre-requiste installation files copied"
cp -v /vagrant/k8s-v1.28.playbook $HOME
#ansible-playbook k8s-v1.28.playbook

echo "[TASK 10] Ensure kubernetes installation files copied"
cp -v /vagrant/k8s-v1.28-install.playbook $HOME
#ansible-playbook k8s-v1.28-install.playbook

echo "[TASK 11] Execute below scripts to login to Vagrant VM and provision kubernetes"
echo "ssh root@193.16.16.11"
echo "ansible-playbook k8s-v1.28.playbook"
echo "ansible-playbook k8s-v1.28-install.playbook"