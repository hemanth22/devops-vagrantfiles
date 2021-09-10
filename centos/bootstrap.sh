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
