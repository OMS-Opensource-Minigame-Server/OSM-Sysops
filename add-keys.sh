#!/bin/sh

#Download a list of admins from github
usernames=$(curl -f "https://raw.githubusercontent.com/OMS-Opensource-Minigame-Server/OSM-Sysops/main/administrators.txt")
status=$?

if [ $status -ne 0 ]
then
  echo "Error downloading members from GitHub! Aborting."
  exit $status
fi

#Download the new keys from github
for username in $usernames
do
  curl -f https://github.com/"$username".keys >> /home/administrator/.ssh/new_authorized_keys
  status=$?
  if [ $status -ne 0 ] 
  then
    echo "Error downloading public keys from GitHub! Aborting."
    rm /home/administrator/.ssh/new_authorized_keys
    exit $status
  fi
done

#Remove the current authorized_keys file
rm /home/administrator/.ssh/authorized_keys

#Replace the current authorized_keys file with the new authorized keys.
mv /home/administrator/.ssh/new_authorized_keys /home/administrator/.ssh/authorized_keys
