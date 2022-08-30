#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hemanth\nhemanth" | passwd root >/dev/null 2>&1

# install epel-release
echo "[TASK 3] install epel-release"
yum install epel-release -y

echo "[TASK 4] install dnf"
yum install dnf -y
yum clean all

echo "[TASK 5] install jq"
yum install jq -y

echo "[TASK 6] install wget"
yum install wget -y

echo "[TASK 7] install opensearch opensearch-dashboards repo"
curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch/2.x/opensearch-2.x.repo -o /etc/yum.repos.d/opensearch-2.x.repo
curl -SL https://artifacts.opensearch.org/releases/bundle/opensearch-dashboards/2.x/opensearch-dashboards-2.x.repo -o /etc/yum.repos.d/opensearch-dashboards-2.x.repo

echo "[TASK 8] install opensearch opensearch-dashboards apps"
yum install opensearch -y
yum install opensearch-dashboards -y

echo "[TASK 9] install opensearch opensearch-dashboards apps"
systemctl status -l opensearch.service
systemctl status -l opensearch-dashboards.service

echo "[TASK 10] Ensure to install net-tools"
dnf install net-tools -y

echo "[TASK 11] Ensure to install bind-utils"
dnf install bind-utils -y

echo "[TASK 12] Ensure to install tree"
dnf -y install tree

echo "[TASK 13] Ensure to install strace"
dnf install -y strace

echo "[TASK 14] Ensure to install traceroute"
dnf install -y traceroute

echo "[TASK 15] Ensure to install sysstat"
dnf install -y sysstat

echo "[TASK 16] Ensure to install netcat"
dnf install -y netcat

echo "[TASK 17] Ensure to install python 3.9"
dnf install -y python39

echo "[TASK 18] Ensure to install ansible"
pip3 install ansible
