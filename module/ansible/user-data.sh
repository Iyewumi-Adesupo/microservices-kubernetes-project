#!/bin/bash

#Update instance and install ansible
sudo apt-get update -y
sudo apt-get install software-properties-common -y
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt-get install ansible python3-pip -y
sudo bash -c ' echo "strictHostKeyChecking No" >> /etc/ssh/ssh_config'

# Copying Private Key into Ansible server and chaning its permission
echo "" >> /home/ubuntu/
sudo chmod 400 /home/ubuntu/
sudo chown ubuntu:ubuntu /home/ubuntu/

#Giving the right permission to ansible directory
sudo chown -R ubuntu:ubuntu /etc/ansible && chmod +x /etc/ansible
sudo chmod 777 /etc/ansible/hosts
sudo chown -R ubuntu:ubuntu /etc/ansible

#copying the 1st HAproxy IP into our ha-ip.yml
sudo echo main_ha_ip: "${HAproxy1}" >> /home/ubuntu/ha-ip.yml

#copying the 2nd HAproxy IP into our ha-ip.yml
sudo echo bckup_ha_ip: "${HAproxy2}" >> /home/ubuntu/ha-ip.yml

#Updating Host Inventory file with all the ip addresses
sudo echo "[haproxy1]" > /etc/ansible/hosts
sudo echo "${HAprox} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "[haproxy2]" >> /etc/ansible/hosts
sudo echo "${HAprox} ansible_ssh_private_key_file=home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "[main-master]" >> /etc/ansible/hosts
sudo echo "${m1} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "[member-master]" >> /etc/ansible/hosts
sudo echo "${m2} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "${m3} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "[worker]" >> /etc/ansible/hosts
sudo echo "${w1} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "${w2} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts
sudo echo "${w3} ansible_ssh_private_key_file=/home/ubuntu/ " >> /etc/ansible/hosts

#Executing all playbooks
sudo su -c "ansible-playbook /home/ubuntu/playbook/installation.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/ha-keepalived.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/main-master.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/member-master.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/worker.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/ha-kubectl.yml" ubuntu
# sudo su -c "ansible-playbook /home/ubuntu/playbook/stage.yml" ubuntu
# sudo su -c "ansible-playbook /home/ubuntu/playbook/prod.yml" ubuntu
sudo su -c "ansible-playbook /home/ubuntu/playbook/monitoring.yml" ubuntu

sudo hostnamectl set-hostname Ansible