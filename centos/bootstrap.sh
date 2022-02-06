#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hemanth\nhemanth" | passwd root >/dev/null 2>&1

echo "[TASK 3] Install yum-utils"
yum install -y yum-utils

echo "[TASK 4] Install net-tools"
yum -y install net-tools

echo "[TASK 5] Install bind-utils"
yum -y install bind-utils

echo "[TASK 6] Install tree"
yum -y install tree

echo "[TASK 7] Install EPEL"
yum install -y epel-release

echo "[TASK 8] Configure repo"
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

echo "[TASK 9] Install terraform"
yum -y install terraform

echo "[TASK 10] Install podman"
yum install -y podman

echo "[TASK 11] Install vsftpd"
yum install -y vsftpd

echo "[TASK 12] Install python3"
yum install -y python3 python3-pip

echo "[TASK 13] Ensure to upgrade pip"
python3 -m pip install --upgrade pip

echo "[TASK 14] Ensure wheel is installed"
python3 -m pip install wheel

echo "[TASK 15] Ensure ansible installed"
python3 -m pip install ansible

echo "[TASK 16] Ensure strace installed"
yum install -y strace

echo "[TASK 17] Ensure traceroute installed"
yum install -y traceroute

echo "[TASK 18] Ensure sysstat installed"
yum install -y sysstat

echo "[TASK 19] Ensure netcat installed"
yum install -y netcat
