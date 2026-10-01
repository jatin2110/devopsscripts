#!/bin/bash

yum install -y wget fontconfig git java-21-amazon-corretto java-21-amazon-corretto-devel maven && \
java --version && \
git --version && \
mvn -version && \
wget -q -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo && \
rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key && \
yum install -y jenkins && \
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java)))) && \
mkdir -p /etc/systemd/system/jenkins.service.d && \
printf '[Service]\nEnvironment="JAVA_HOME=%s"\nEnvironment="JENKINS_JAVA_CMD=%s/bin/java"\n' "$JAVA_HOME_PATH" "$JAVA_HOME_PATH" > /etc/systemd/system/jenkins.service.d/java.conf && \
systemctl daemon-reload && \
systemctl enable --now jenkins







#STEP-1: Installing Git and Maven
yum install git maven -y

#STEP-2: Repo Information (jenkins.io --> download -- > redhat)
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

#STEP-3: Download Java 21 and Jenkins
sudo yum install java-21-amazon-corretto -y
yum install jenkins -y
sudo mount -o remount,size=2G /tmp
#STEP-4: Start and check the JENKINS Status
systemctl start jenkins.service
systemctl status jenkins.service

#STEP-5: Auto-Start Jenkins
chkconfig jenkins on
