#!/bin/bash

# Update system
dnf upgrade -y

# Install required packages
dnf install -y wget curl fontconfig git java-21-openjdk java-21-openjdk-devel maven

# Set JAVA_HOME
JAVA_HOME_PATH=$(dirname $(dirname $(readlink -f $(which java))))

cat >> /etc/profile <<EOF
export JAVA_HOME=$JAVA_HOME_PATH
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

export JAVA_HOME=$JAVA_HOME_PATH
export PATH=$JAVA_HOME/bin:$PATH

# Verify Java
java --version

# Verify Git
git --version

# Verify Maven
mvn --version

# Add official Jenkins LTS repository
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/rpm-stable/jenkins.repo

# Import Jenkins GPG key
rpm --import https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key

# Refresh repositories
dnf clean all
dnf makecache -y

# Install Jenkins
dnf install -y jenkins

# Configure Jenkins to use Java 21
mkdir -p /etc/systemd/system/jenkins.service.d

cat > /etc/systemd/system/jenkins.service.d/java.conf <<EOF
[Service]
Environment="JAVA_HOME=$JAVA_HOME_PATH"
Environment="JENKINS_JAVA_CMD=$JAVA_HOME_PATH/bin/java"
EOF

# Reload systemd
systemctl daemon-reload

# Enable Jenkins at boot
systemctl enable jenkins

# Start Jenkins
systemctl start jenkins

# Show versions
echo "======================================"
echo "Java:"
java --version

echo "======================================"
echo "Git:"
git --version

echo "======================================"
echo "Maven:"
mvn --version

echo "======================================"
echo "Jenkins:"
/usr/bin/jenkins --version

echo "======================================"
echo "Jenkins Service:"
systemctl status jenkins --no-pager







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
