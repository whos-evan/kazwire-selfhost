#!/bin/bash

# ask the user if they would like to proceed with the installation
echo "WARNING IS ONLY MEANT FOR UBUNTU 20.04 SERVERS! Run at your own risk!"
echo "This script will install the latest version of the open source version of the Kazwire. It will auto install any dependencies needed. It will also install bare-server and Caddy using Docker. Would you like to proceed? (Y/n)"
read -r proceed
if [ "$proceed" = "n" ]; then
  echo "Exiting..."
  exit 0
fi

# check for dependencies (git and nano)
dependencies=(git nano)
for dependency in "${dependencies[@]}"; do
  if ! [ -x "$(command -v $dependency)" ]; then
    echo "Installing $dependency..."
    apt-get update && apt-get install -y $dependency
  fi
done

# check for docker
if ! [ -x "$(command -v docker)" ]; then
  echo 'Installing Docker...'
  curl -fsSL https://get.docker.com -o get-docker.sh
  DRY_RUN=1 sudo sh ./get-docker.sh
fi

# check for docker-compose
# if the output of the command docker compose is "docker: 'compose' is not a docker command." then docker-compose is not installed
if [ "$(docker compose)" = "docker: 'compose' is not a docker command." ]; then
  echo 'Installing Docker Compose...'
  apt-get update && apt-get install -y docker-compose-plugin
fi

# check to make sure that the user is running this script as root
if [ "$(id -u)" != "0" ]; then
  echo "Error: This script must be run as root. Please run it as root." >&2
  exit 1
fi

# ensure the user has at least 10 GB of free space
free_space=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [ "$free_space" -lt "10" ]; then
  echo "Error: You do not have enough free space to run this script. Please free up at least 10 GB of space and try again." >&2
  exit 1
fi

# ask the user if they would like to proceed
echo "This script will install the latest version of the open source version of the Kazwire. It will also install bare-server and Caddy. Would you like to proceed? (Y/n)"
read -r proceed
if [ "$proceed" = "n" ]; then
  echo "Exiting..."
  exit 0
fi

# clone the repository
git clone https://github.com/whos-evan/kazwire.git

# prompt the user to change the domain name in the caddyfile
echo "Please change the domain name in the Caddyfile to your domain name that is pointed to this server. Please also ensure that the server has the ports 443 and 80 open. Press enter to continue."
read -r
nano caddy/Caddyfile

# prompt the user to continue
echo "Do you want to continue with the installation? (Y/n)"
read -r proceed
if [ "$proceed" = "n" ]; then
  echo "Exiting..."
  exit 0
fi

# run the docker compose file
echo "Pulling the latest images and starting the containers..."
docker-compose pull
docker-compose up -d

# tell the user that the script has finished
echo "The script has finished. Please visit your domain name!"
