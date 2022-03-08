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

function install_go() {
  ver="1.17.5"
  cd ~
  wget --inet4-only "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  rm -rf /usr/local/go
  tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.profile
  source ~/.profile
}

function install_node_sources() {
  git clone https://github.com/masa-finance/masa-node-v1.0
  cd masa-node-v1.0/src
  make all
  echo 'export PATH=$PATH:/root/masa-node-v1.0/src/build/bin' >> ~/.profile
  source ~/.profile
  cd ../node
  geth --datadir data init ../network/testnet/genesis.json
  
  echo
  read -r -p "Enter your identity: " IDENTITY
  echo

  echo "[Unit]
Description=Masa Service
After=network.target

[Service]
Type=simple
User=root
Group=root
Environment=PRIVATE_CONFIG=ignore
WorkingDirectory=/root/masa-node-v1.0/node
ExecStart=/root/masa-node-v1.0/src/build/bin/geth \
--identity ${IDENTITY} \
--datadir /root/masa-node-v1.0/node/data \
--bootnodes enode://91a3c3d5e76b0acf05d9abddee959f1bcbc7c91537d2629288a9edd7a3df90acaa46ffba0e0e5d49a20598e0960ac458d76eb8fa92a1d64938c0a3a3d60f8be4@54.158.188.182:21000,enode://571be7fe060b183037db29f8fe08e4fed6e87fbb6e7bc24bc34e562adf09e29e06067be14e8b8f0f2581966f3424325e5093daae2f6afde0b5d334c2cd104c79@142.132.135.228:21000,enode://269ecefca0b4cd09bf959c2029b2c2caf76b34289eb6717d735ce4ca49fbafa91de8182dd701171739a8eaa5d043dcae16aee212fe5fadf9ed8fa6a24a56951c@65.108.72.177:21000 \
--emitcheckpoints \
--istanbul.blockperiod 1 \
--mine \
--miner.threads 1 \
--syncmode full \
--verbosity 4 \
--networkid 190250 \
--rpc \
--rpccorsdomain "*" \
--rpcvhosts "*" \
--rpcaddr 127.0.0.1 \
--rpcport 8545 \
--rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,istanbul \
--port 30300 
KillMode=process
KillSignal=SIGINT
TimeoutStopSec=90
Restart=on-failure
RestartSec=10s
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/masad.service
  systemctl daemon-reload
  systemctl enable masad
  systemctl start masad

  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN$BOLD"Success!"$NC "Your Masa node is installed correctly and working, you can check it with" $BOLD"journalctl -u masad -f"$NC
  else 
    echo -e $RED$BOLD"Error!"$NC "Something went wrong during Masa node installation. Please try again"
    exit 1
  fi
}

echo
echo -e ${BOLD}'Official Telegram: '$BLUE'https://t.me/masafinance'$NC
echo -e ${BOLD}'      RU Telegram: '$BLUE'https://t.me/MasaFinanceRus'$NC
echo

PS3='Please select action: '
options=("Install" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Install")
            echo "You chose $opt..."
            install_soft
            install_go
            install_node_sources
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done