locals {
  jenkins_user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo yum install git -y
sudo yum install maven -y
sudo yum install wget -y
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum upgrade -y
sudo yum install java-17-openjdk -y
sudo systemctl daemon-reload
sudo yum install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo hostnamectl set-hostname jenkins
EOF
}