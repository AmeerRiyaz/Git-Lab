#!/bin/bash

echo "🔧 Killing running apt/dpkg processes..."
sudo killall -q apt apt-get dpkg

echo "🔒 Removing apt and dpkg locks..."
sudo rm -f /var/lib/dpkg/lock-frontend
sudo rm -f /var/lib/dpkg/lock
sudo rm -f /var/cache/apt/archives/lock
sudo rm -f /var/lib/apt/lists/lock

echo "⚙️ Fixing dpkg state..."
sudo dpkg --configure -a

echo "🧹 Removing GitLab packages and files..."
sudo dpkg --purge --force-remove-reinstreq gitlab-ce gitlab-ee
sudo apt purge -y gitlab-ce gitlab-ee
sudo apt autoremove --purge -y

echo "🗑️ Deleting GitLab data and config folders..."
sudo rm -rf /opt/gitlab /etc/gitlab /var/log/gitlab /var/opt/gitlab

echo "✅ GitLab cleanup completed."
