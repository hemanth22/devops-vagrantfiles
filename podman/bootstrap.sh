#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "hemanth\nhemanth" | passwd root >/dev/null 2>&1

echo "[TASK 3] Install podman"
yum install -y podman

echo "[TASK 4] Install python3"
yum install python3-pip -y

echo "[TASK 5] Install pip for python3"
easy_install-3.6 pip

echo "[TASK 6] Upgrade pip for python3"
pip3 install --upgrade pip

echo "[TASK 7] Intall forex-python pip module"
pip3 install forex-python

echo "[TASK 8] Intall tree"
yum install tree -y