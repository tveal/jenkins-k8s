#!/bin/bash
set -e

# https://docs.docker.com/install/linux/docker-ce/ubuntu/#set-up-the-repository
# non-sudo priv: https://docs.docker.com/install/linux/linux-postinstall/#manage-docker-as-a-non-root-user
function main() {
	apt update
	apt install -y \
		apt-transport-https \
		ca-certificates \
		curl \
		software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
	add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
	apt update
	apt install -y docker-ce
	usermod -aG docker $SUDO_USER
	echo "Finished Docker CE Setup"
	echo "-> You will need to logout and back in for docker permissions to work."
}

# intended use: checkIfRoot && ...
function checkIfRoot() {
	if [ "$EUID" -ne 0 ]; then
		echo "--! Please run as root"
		return -1
	else
		return 0
	fi
}

echo "Docker CE Setup"
checkIfRoot && main
