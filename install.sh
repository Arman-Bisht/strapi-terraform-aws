#!/bin/bash
set -e

# Log output
exec > >(tee /var/log/strapi-install.log)
exec 2>&1

echo "Starting Strapi installation..."

# ===== MEMORY FIX: Create 2GB Swap Space =====
echo "Creating swap space to handle Strapi's memory requirements..."
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

# Optimize swap usage
sysctl vm.swappiness=10
echo 'vm.swappiness=10' | tee -a /etc/sysctl.conf

echo "Swap space created successfully!"
free -h

# Update system
apt-get update
apt-get upgrade -y

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Verify Node.js installation
node --version
npm --version

# Install PM2 globally
npm install -g pm2

# Create strapi directory
mkdir -p /srv/strapi
cd /srv/strapi

# Create Strapi app as ubuntu user
sudo -u ubuntu bash << 'EOF'
cd /srv/strapi
npx create-strapi-app@latest my-project --quickstart --no-run
cd my-project

# Build admin panel
NODE_ENV=production npm run build

# Start with PM2
pm2 start npm --name "strapi" -- start
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu
EOF

# Enable PM2 startup
env PATH=$PATH:/usr/bin pm2 startup systemd -u ubuntu --hp /home/ubuntu

echo "Strapi installation completed!"
echo "Access Strapi at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):1337"
