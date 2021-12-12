RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

function install_soft() {
  apt-get -y update && apt-get -y upgrade && apt-get -y install net-tools git jq nano htop curl make gcc zip unzip gpg build-essential ncdu
}

function setup_vpn() {
  DISTRO=$(lsb_release -cs)

  apt install -y apt-transport-https
  curl -fsSL https://swupdate.openvpn.net/repos/openvpn-repo-pkg-key.pub | gpg --dearmor > /etc/apt/trusted.gpg.d/openvpn-repo-pkg-keyring.gpg
  curl -fsSL https://swupdate.openvpn.net/community/openvpn3/repos/openvpn3-$DISTRO.list >/etc/apt/sources.list.d/openvpn3.list
  apt update && apt -y install openvpn3

  OVPN_CONFIG=~/masa-testnet-dev-client-community.ovpn
  openvpn3 session-start --config $OVPN_CONFIG

  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN "VPN is configured!" $NC
  else 
    echo -e $RED "VPN is NOT configured!" $NC "Please try again"
    exit 1
  fi
}

function install_docker() {
  apt-get -y install ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

  apt-get update
  apt-get -y install docker-ce docker-ce-cli containerd.io
  docker run hello-world

  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN "Docker is configured!" $NC
  else 
    echo -e $RED "Docker is NOT configured!" $NC "Please try again"
    exit 1
  fi

  curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
  docker-compose --version

  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN "docker-composer is configured!" $NC
  else 
    echo -e $RED "docker-composer is NOT configured!" $NC "Please try again"
    exit 1
  fi
}

function install_node() {
  git clone https://github.com/masa-finance/masa-node-v1.0
  cd masa-node-v1.0
  PRIVATE_CONFIG=ignore docker-compose up -d
  if [ $? -eq 0 ] 
  then 
    echo -e $GREEN "Success!" $NC "Your Masa node is installed correctly and working"
  else 
    echo -e $RED "Error!" $NC "Something went wrong during Masa node installation. Please try again"
    exit 1
  fi
}

install_soft
setup_vpn
install_docker
install_node