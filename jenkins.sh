#!/bin/bash

set -e

echo "========================================="
echo " Jenkins Installation - Amazon Linux 2023"
echo "========================================="

# --------------------------------------------------
# 1. Update system
# --------------------------------------------------

echo "[1/10] Updating system..."
dnf update -y


# --------------------------------------------------
# 2. Create 2 GB SWAP BEFORE installing packages
# --------------------------------------------------

echo "[2/10] Creating 2 GB swap..."

if ! swapon --show | grep -q "/swapfile"; then

    if [ ! -f /swapfile ]; then
        fallocate -l 2G /swapfile
    fi

    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
fi

if ! grep -q "^/swapfile " /etc/fstab; then
    echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
fi

echo "Swap status:"
free -h


# --------------------------------------------------
# 3. PERMANENT /tmp FIX
# --------------------------------------------------
#
# Amazon Linux 2023 uses tmpfs for /tmp.
# Jenkins monitors /tmp and may take the node offline
# when the free space is below 1 GiB.
#
# We disable the tmpfs /tmp mount so /tmp uses the
# 20 GB EBS root filesystem instead.
# --------------------------------------------------

echo "[3/10] Configuring permanent /tmp..."

# Stop Jenkins if already installed
systemctl stop jenkins 2>/dev/null || true

# Disable and mask Amazon Linux tmpfs mount
systemctl disable --now tmp.mount 2>/dev/null || true
systemctl mask tmp.mount 2>/dev/null || true

# If /tmp is still mounted as tmpfs, unmount it
if mountpoint -q /tmp; then
    umount /tmp || true
fi

# Make sure /tmp exists
mkdir -p /tmp

# Standard permissions for /tmp
chmod 1777 /tmp

echo "Checking /tmp:"
df -h /tmp


# --------------------------------------------------
# 4. Install required packages
# --------------------------------------------------

echo "[4/10] Installing required packages..."

dnf install -y \
    wget \
    curl \
    fontconfig \
    git \
    java-21-openjdk \
    java-21-openjdk-devel \
    maven


# --------------------------------------------------
# 5. Configure Java 21 as default
# --------------------------------------------------

echo "[5/10] Configuring Java 21..."

alternatives --set java /usr/lib/jvm/java-21-openjdk/bin/java 2>/dev/null || true

if [ -x /usr/lib/jvm/java-21-openjdk/bin/java ]; then
    export JAVA_HOME=/usr/lib/jvm/java-21-openjdk
else
    JAVA_PATH=$(dirname "$(dirname "$(readlink -f "$(which java)")")")
    export JAVA_HOME="$JAVA_PATH"
fi

echo "JAVA_HOME=$JAVA_HOME"
java --version


# --------------------------------------------------
# 6. Configure Jenkins repository
# --------------------------------------------------

echo "[6/10] Adding Jenkins repository..."

wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/rpm-stable/jenkins.repo

rpm --import \
    https://pkg.jenkins.io/rpm-stable/jenkins.io-2026.key


# --------------------------------------------------
# 7. Install Jenkins
# --------------------------------------------------

echo "[7/10] Installing Jenkins..."

dnf install -y jenkins


# --------------------------------------------------
# 8. Configure Jenkins to use Java 21
# --------------------------------------------------

echo "[8/10] Configuring Jenkins Java..."

mkdir -p /etc/systemd/system/jenkins.service.d

cat > /etc/systemd/system/jenkins.service.d/java.conf <<EOF
[Service]
Environment="JAVA_HOME=$JAVA_HOME"
Environment="JENKINS_JAVA_CMD=$JAVA_HOME/bin/java"
EOF


# --------------------------------------------------
# 9. Reload and start Jenkins
# --------------------------------------------------

echo "[9/10] Starting Jenkins..."

systemctl daemon-reload
systemctl enable jenkins
systemctl restart jenkins


# --------------------------------------------------
# 10. Final verification
# --------------------------------------------------

echo "[10/10] Final verification..."

echo
echo "========================================="
echo " JAVA"
echo "========================================="
java --version

echo
echo "========================================="
echo " MAVEN"
echo "========================================="
mvn --version

echo
echo "========================================="
echo " GIT"
echo "========================================="
git --version

echo
echo "========================================="
echo " SWAP"
echo "========================================="
free -h

echo
echo "========================================="
echo " /tmp"
echo "========================================="
df -h /tmp

echo
echo "========================================="
echo " ROOT DISK"
echo "========================================="
df -h /

echo
echo "========================================="
echo " JENKINS"
echo "========================================="
systemctl --no-pager --full status jenkins

echo
echo "========================================="
echo " INSTALLATION COMPLETE"
echo "========================================="
echo
echo "Jenkins URL:"
echo "http://$(hostname -I | awk '{print $1}'):8080"
echo
echo "Initial Admin Password:"
cat /var/lib/jenkins/secrets/initialAdminPassword
echo



















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
