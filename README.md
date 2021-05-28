# OSM-Sysops

This project contains the scripts we currently use to initialize our servers.

### Script Description

* add-keys.sh: This script adds the SSH keys of our current administrators into our servers.
* init-node.sh: This script verifies some requirements to join our cluster, installs the add-keys.sh script to run daily and installs Docker/Kubernetes and joins the server to our Kubernetes cluster.

