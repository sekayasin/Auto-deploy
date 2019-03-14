# Learning DevOps  - Auto Deploy

###### :page_facing_up: Auto Deploy

This is repo 1 - Deploying my project. This is used to aid my learning as a DevOps Engineer. 
This is a bash script that will deploy my frontend app (React&Redux App) from bottom up.
- Setup Nginx as a Reverse proxy for the React App running on port 3000 
- Use letsencrypt to install SSL
- Create a systemd service to run the app in the background
- Add a Domain name of your choice and Leverage AWS Route 53 to create DNS Records to point to your hosted project public IP on AWS EC2

## Description of the Process and Steps to Deploy this Project

---
#### Screencast
Check [here](https://drive.google.com/open?id=1llrduFuoIlLlDgDxoGVwLmIIQNOAj8ET) for a recorded screencast showing how the script works.

---

#### How to Deploy this Project
1. Spin Up an AWS EC2 Instance
- Login to AWS Console and spin up an EC2 instnace, probably an instance running Ubuntu 18.04 LTS
- You can reserve an Elastic Public IP for the EC2 instance, for Demo purpose, I will use the Public IP assigned to the instance
- Configure a security group, add rules to open up the instance on port 80 (HTTP), 443 (HTTPS) and allow SSH access (port 22) from anywhere, this can be restricted to your public IP, allowing it to only access the instance via SSH.
2. Copy the script to AWS EC2 instance
- SSH into your instance using it's dynamic assigned public IP or it's Elastic IP if reserved one for it.
- Clone this Repository `git clone https://github.com/sekayasin/Auto-deploy.git`
- Navigate into the Project directory `cd Auto-deploy`
- Make the script executable `chmod +x ec2_auto_deploy.sh`
- Optionally, you can git clone this repository on your local working computer, cd into Auto-deploy directory, and copy the script to your AWS EC2 instance using `scp` or `rsync` commands, SSH into your instance and finally run the script.
- Run the script `./ec2_auto_deploy.sh`


---

#### Tools used
1. AWS   -   Amazon Web Services is a subsidiary of Amazon that provides on-demand cloud computing platforms to individuals, companies, and governments, on a paid subscription basis.
2. Amazon EC2  - Amazon Elastic Compute Cloud (Amazon EC2) is a web service that provides resizable compute capacity in the cloud. 
3. Amazon Route 53 - Route 53 is a scalable and highly available Domain Name System (DNS) service. 
4. Freenom -  Freenom is the world’s first and only free domain provider - I used freenom to register my domain name.
   
---

###### :microscope: NOTE

This script automatically deploys my simulation project (Frontend React/Redux App) on AWS EC2 Instance

- [x] Tested on AWS EC2 instance running Ubuntu 18.04 LTS
- [x] FYI: Deployed the Frontend of the Simulation Project (which is a React/Redux application)
- [x] FYI: The React frontend application is configured by setting up Webpack + Babel. 

1. When the script successful executes without errors, below are the services it will set up and install;
- Install Nodejs version 10, and install yarn package manager globally
- Install Nginx web server and set it up as a reverse proxy listening on port 80, serving our react frontend app running on port 3000.
- Install Certbot packages and Configure SSL certificates for our domain
- Create a systemd service that will enable to run the application in the background, and in case the application fails, the systemd service can always auto start the application
 
---
