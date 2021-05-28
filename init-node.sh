#!/bin/bash

LSB=$(lsb_release -d)
VERSION="Ubuntu 18.04.5 LTS"

if [[ ${LSB} != *"$VERSION"* ]];then
  echo "Operating System doesn't match the required $VERSION, aborting!"
  exit 1
fi

free -h
read -p "Please ensure swap is disabled!" asd

echo "Installing key updater"
curl https://raw.githubusercontent.com/OMS-Opensource-Minigame-Server/OSM-Sysops/main/add-keys.sh > /etc/cron.daily/addkeys.sh
chmod +x /etc/cron.daily/addkeys.sh
/etc/cron.daily/addkeys.sh

echo "Allowing admin group to run sudo passwordless"
echo "administrator ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers

echo "Installing Docker prerequisites"
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

echo "Installing Docker 18.0.9"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install -y docker-ce=5:18.09.9~3-0~ubuntu-bionic docker-ce-cli=5:18.09.9~3-0~ubuntu-bionic
sudo apt-mark hold docker-ce docker-ce-cli

echo "Setting Kubernetes prerequisites"
sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

echo "Installing Kubernetes"
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet=1.18.19-00 kubeadm=1.18.19-00 kubectl=1.18.19-00
sudo apt-mark hold kubelet kubeadm kubectl

echo "Joining node to the cluster"
read -p "Enter the Kubernetes master hostname: " khostname
read -p "Enter the Kubernetes token: " ktoken
read -p "Enter the Kubernetes discovery-token-ca-cert-hash: " kcerthash

kubeadm join "$khostname:6443" --token "$ktoken" --discovery-token-ca-cert-hash "sha256:$kcerthash"
