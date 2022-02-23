#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

function install_soft() {
  apt-get -y update && apt-get -y upgrade && apt-get -y install net-tools git jq nano htop curl make gcc zip unzip gpg build-essential ncdu
}

function install_docker() {
  apt-get -y install ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update
  apt-get -y install docker-ce docker-ce-cli containerd.io
  docker run hello-world >/dev/null 2>&1

  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN$BOLD"Docker is configured!"$NC
  else 
    echo -e $RED$BOLD"Docker is NOT configured!"$NC "Please try again"
    exit 1
  fi

  curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  docker-compose --version

  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN$BOLD"docker-composer is configured!"$NC
  else 
    echo -e $RED$BOLD"docker-composer is NOT configured!"$NC "Please try again"
    exit 1
  fi
}

function install_node() {
  git clone https://github.com/masa-finance/masa-node-v1.0
  echo "[Unit]
Description=Masa Node

[Service]
User=root
ExecStart=(/root/masa.sh <<< 2)
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/masad.service 
  echo -e $GREEN$BOLD"Success!"$NC "Your Masa node is installed and ready to work"
}

function suggest_reboot() {
  while true; do
    read -p "$(echo -e "It's" $BOLD"highly"$NC "recommended to reboot your server after Masa installation. Reboot? [Y/n]" )" yn
    case $yn in
        [Yy]* ) reboot; break;;
        '' ) reboot; break;;
        [Nn]* ) break;;
        * ) echo "Type Y or N";;
    esac
  done
}

function run_node() {
  cd masa-node-v1.0
  PRIVATE_CONFIG=ignore docker-compose up -d
  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN$BOLD"Success!"$NC "Your Masa node is working"
  else 
    echo -e $RED$BOLD"Error!"$NC "Something went wrong during Masa node start. Please try again"
    exit 1
  fi
}

echo
echo -e ${BOLD}'Official Telegram: '$BLUE'https://t.me/masafinance'$NC
echo -e ${BOLD}'      RU Telegram: '$BLUE'https://t.me/MasaFinanceRus'$NC
echo

PS3='Please select action: '
options=("Install Masa node" "Run Masa node" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install Masa node")
            echo "You chose $opt..."
            install_soft
            install_docker
            install_node
            suggest_reboot
            break
            ;;
        "Run Masa node")
            echo "You chose $opt..."
            run_node
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done