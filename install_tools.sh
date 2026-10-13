#!/bin/bash

# 1. Prevent the "Purple Screen" prompt from hanging the installation
export DEBIAN_FRONTEND=noninteractive

# Update system
sudo apt-get update -y

# --- INSTALL DOCKER (Modern Secure Way) ---
sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ubuntu

# 1. Install Java (Jenkins requires Java 17)
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-17-jre

# 2. Add Jenkins Key and Repository
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 3. Update apt again and install Jenkins
sudo apt-get update
sudo apt-get install -y jenkins

# 4. Start and Enable Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins