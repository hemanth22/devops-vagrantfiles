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