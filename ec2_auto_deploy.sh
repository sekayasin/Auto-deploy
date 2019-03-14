#!/bin/bash

# set options and positional parameters
# -e exit the shell immediately if a command fails or returns an exit status value > 0
# -u when expand a variable that is not set, exit immediately write a message to standard error
# -o write current settings of the options to standard output in an unspecified format.

set -euo pipefail 

DOMAIN='fastfoodfast.tk'
EMAIL='sekayasin@gmail.com'
REMOTE_REPO_URL='https://github.com/sekayasin/3Fs.git'
LOCAL_REPO_DIR='3Fs'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
ORANGE='\033[0;33m'

installationColor(){
   echo -e "${ORANGE}------------------------------------------------------------------------------------------${NC}"
   echo -e "${ORANGE} $1                                                                                       ${NC}"
   echo -e "${ORANGE}------------------------------------------------------------------------------------------${NC}"   
}

cleaningInstallationPackages(){
   echo -e "${RED}------------------------------------------------------------------------------------------${NC}"
   echo -e "${RED} $1                                                                                       ${NC}"
   echo -e "${RED}------------------------------------------------------------------------------------------${NC}"   
}

doneInstallationProcess(){
   echo -e "${GREEN}------------------------------------------------------------------------------------------${NC}"
   echo -e "${GREEN} $1                                                                                       ${NC}"
   echo -e "${GREEN}------------------------------------------------------------------------------------------${NC}"   
}

initalServerUpdate() {
    installationColor "Update server and upgrade"
    
    sudo apt update
    sudo apt upgrade -y

    doneInstallationProcess "Server update and upgrade... Done!"
}

initialPackageInstallation() {
    installationColor "Installing all necessary software packages, python3, nginx, curl, postgresql, nodejs"
    
    sudo apt install python3-pip python3-dev libpq-dev postgresql postgresql-contrib nginx curl -y

    doneInstallationProcess "Installed neccessary software packages... Done!"
}

installNodejs() {
    installationColor  "Installing Nodejs and yarn"
    
    curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
    sudo apt -y install nodejs
    sudo apt -y install libtool pkg-config build-essential autoconf automake
    sudo npm i yarn -g

    doneInstallationProcess "Nodejs and yarn installed... Done!"
}

installCerbot() {
    installationColor "Install certbot"
    
    sudo apt -y install software-properties-common
    sudo add-apt-repository universe
    sudo add-apt-repository ppa:certbot/certbot -y
    sudo apt update
    sudo apt -y install certbot python-certbot-nginx 

    doneInstallationProcess "Cerbot package installed... Done!"
}

configureFirewall() {
    # Add exception for SSH and then enable UFW firewall
    
    installationColor "Configure firewall"
    
    sudo ufw allow OpenSSH
    sudo ufw allow 80
    sudo ufw allow 443
    sudo ufw allow in 443/tcp comment "https: for certbot"
    sudo ufw allow 'Nginx HTTP'
    sudo ufw --force enable
    sudo ufw status

    doneInstallationProcess "Firewall rules updated... Done!"
}

cloneProjectRepo() {
    # clone the project repo
    
    installationColor "clone project repo"

    if [ -d $LOCAL_REPO_DIR ]; then
        echo "Directory $LOCAL_REPO_DIR already exists, cleaning..."
        sudo rm -fr $LOCAL_REPO_DIR
        git clone $REMOTE_REPO_URL
    else 
        git clone $REMOTE_REPO_URL
    fi

    doneInstallationProcess "Project repo cloned... Done!"
}

installProjectDependencies() {
    # install dependencies
    
    installationColor "install project dependencies"

    cd $LOCAL_REPO_DIR

    sudo yarn
    sudo yarn build

    doneInstallationProcess "project dependencies installed and project is build... Done!"
    
}


configureNginx() {
    installationColor "Configure Nginx"

    sudo rm -fr /etc/nginx/sites-enabled/default
    
    if [[ -f /etc/nginx/sites-enabled/fastfoodfast ]]; then

      cleaningInstallationPackages "Remove Existing Configurations"

      sudo rm -fr /etc/nginx/sites-enabled/fastfoodfast
      sudo rm -fr /etc/nginx/sites-available/fastfoodfast
    fi      
     
    sudo bash -c 'cat > /etc/nginx/sites-available/fastfoodfast <<EOF
    server {
        listen 80;
        server_name fastfoodfast.tk www.fastfoodfast.tk;

        location / {
            proxy_pass  http://localhost:3000;
        }
    }
EOF'

    sudo ln -s /etc/nginx/sites-available/fastfoodfast /etc/nginx/sites-enabled/fastfoodfast
    
    sudo nginx -t
    sudo systemctl enable nginx
    sudo systemctl start nginx

    doneInstallationProcess "Nginx configured... Done!"
}

configureCertbot() {
    installationColor "Configure Certbot  and install ssl certificates"
    
    sudo certbot --nginx -d ${DOMAIN} -d www.${DOMAIN} -n --agree-tos -m ${EMAIL} --redirect --expand
    sudo systemctl restart nginx

    doneInstallationProcess "Installed ssl certificates.... Done!"
}

createSystemdService() {
    installationColor "Creating Systemd Service to run app in the background"
    
    if [[ -f /etc/systemd/system/fastfoodfast.service ]]; then

      cleaningInstallationPackages "Clean existing systemd fastfoodfast service"

      sudo systemctl disable fastfoodfast.service
      sudo rm -fr /etc/systemd/system/fastfoodfast.service
    fi

    sudo bash -c 'cat > /etc/systemd/system/fastfoodfast.service <<EOF
    [Unit]
    Description=fastfoodfast Service - Service to start fast food fast app
    After=network.target

    [Service]
    ExecStart=/usr/bin/node /home/ubuntu/3Fs/server.js
    Restart=on-failure
    Type=simple
    User=ubuntu

    [Install]
    WantedBy=multi-user.target
EOF'

    sudo systemctl daemon-reload
    sudo systemctl enable fastfoodfast.service
    sudo systemctl start fastfoodfast.service

    doneInstallationProcess "fastfoodfast systemd service created... Done!"
}

finishProcess(){
    doneInstallationProcess  "Script run successful.... Check on the deployed app using the IP below. Cheers"
    sudo curl ifconfig.co
}

main() {
    initalServerUpdate
    initialPackageInstallation
    installNodejs
    installCerbot
    configureFirewall
    cloneProjectRepo
    installProjectDependencies
    configureNginx
    configureCertbot
    createSystemdService
    finishProcess
}

main
