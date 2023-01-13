#!/bin/bash

# check for docker
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: Docker must be installed for this script to work. Please refer to the documentation for details.' >&2
  exit 1
fi

# check for docker-compose
# if the output of the command docker compose is "docker: 'compose' is not a docker command." then docker-compose is not installed
if [ "$(docker compose)" = "docker: 'compose' is not a docker command." ]; then
  echo 'Error: Docker Compose must be installed for this script to work. Please refer to the documentation for details.' >&2
  exit 1
fi

# check for git
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: Git must be installed for this script to work. Please refer to the documentation for details.' >&2
  exit 1
fi

# check for nano
if ! [ -x "$(command -v nano)" ]; then
  echo 'Error: Nano must be installed for this script to work. Please refer to the documentation for details.' >&2
  exit 1
fi

# check to make sure that the user is running this script as root
if [ "$(id -u)" != "0" ]; then
  echo "This script must be run as root. Please run it as root." 1>&2
  exit 1
fi

# ensure the user has at least 10 GB of free space
if [ "$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')" -lt "10" ]; then
  echo "You do not have enough free space to run this script. Please free up at least 10 GB of space and try again." 1>&2
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
docker compose pull
docker compose up -d

# tell the user that the script has finished
echo "The script has finished. Please visit your domain name!"

