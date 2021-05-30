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

echo "Installing Useful Utilities"
sudo apt-get update
sudo apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common

echo "Installing Microk8s"
sudo snap install microk8s --classic --channel=1.19/stable
sudo ufw allow in on cni0 && sudo ufw allow out on cni
sudo ufw default allow routed

sudo usermod -a -G microk8s administrator
sudo chown -f -R administrator ~/.kube
sudo snap alias microk8s.kubectl kubectl


read -r -n 1 -t 10 -p "If you would like to manually join the Microk8s cluster, please press any key!" mk8sjoin
EXIT_STATUS=$?
if [ $EXIT_STATUS -eq 0 ]; then

  echo "Joining node to the cluster"
  read -r -p "Enter the Microk8s master hostname and port, e.g. 10.100.100.18:25000: " mk8shostname
  read -r -p "Enter the Microk8s join token: " mk8stoken

  sudo microk8s join "$mk8shostname/$mk8stoken"
fi