#!/bin/bash

# Check to make sure the dependencies are installed
for d in git docker docker-compose; do
    hash "$d" &>/dev/null || { echo -e "\e[31m$d doesn't look to be installed. Exiting\e[0m"; exit 1; }
done

# Download the latest compose file if needed
if [ ! -f "./docker-compose.prod.yml" ]; then
    wget -q -O docker-compose.yml "https://raw.githubusercontent.com/Crossedfall/Website/master/docker-compose.prod.yml"
fi

# Check if config exists, if it doesn't checkout the config from upstream
if [ -d "./config" ]; then
    echo -e "\e[32mConfig directory detected. Using local files\e[0m\n"
else
    echo -e "\e[31mConfig not found. Pulling latest config from upstream....\e[0m"
    git init -q
    git remote add origin https://github.com/crossedfall/Website
    git fetch --depth=5 -q
    git config core.sparseCheckout true
    echo "src/app/config" >> .git/info/sparse-checkout
    git pull -q origin master
    mv ./src/app/config ./config
    rm -rf ./src .git
    echo -e "\e[32mConfig loaded\e[0m\n"
fi

# Build/update the docker image
echo -e "\e[31mBuilding docker environment\e[0m\n"
docker-compose up --quiet-pull --force-recreate --build --no-start
echo -e "====================================="
echo -e "Ready! Use \e[41mdocker-compose up\e[0m to start the service with logging. Use \e[41mdocker-compose up -d\e[0m if you want it to run in the background."