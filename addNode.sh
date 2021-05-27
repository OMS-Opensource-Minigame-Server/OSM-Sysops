#!/bin/sh
free -h
read -p "Please ensure swap is disabled!" asd

echo "Installing key updater"
curl https://raw.githubusercontent.com/OMS-Opensource-Minigame-Server/OSM-Sysops/main/addkeys.sh > /etc/cron.daily/addkeys.sh
chmod +x /etc/cron.daily/addkeys.sh
/etc/cron.daily/addkeys.sh

echo "Allowing admin group to run sudo passwordless"
echo "administrator ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers


echo "Installing docker"
curl https://get.docker.com/ | sudo bash -

echo "Installing kubeadm"
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

echo "Joining node to the cluster"
read -p "Enter the kubernetes token: " token

kubeadm join k8.reallyisnt.fun:6443 --token $token --discovery-token-ca-cert-hash sha256:a4d41f2d8cb1a25d39a2dad907197a450cc7f8658c08ea36bb193d88a742a043