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

echo "[TASK 4] Install hashicorp repo"
yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

echo "[TASK 5] Install vault"
yum -y install vault

echo "[TASK 6] Install net-tools"
yum -y install net-tools

echo "[TASK 7] Install bind-utils"
yum -y install bind-utils

echo "[TASK 8] Install tree"
yum -y install tree

echo "[TASK 9] Install EPEL"
yum install -y epel-release

echo "[TASK 10] Install jq"
yum install -y jq