#!/bin/bash
set -e

# Install dependencies
apt update -y
apt install -y git unzip snapd
snap install bun-js

# Run app setup as ubuntu user
sudo -u ubuntu bash <<'EOF'
set -e
cd /home/ubuntu
git clone https://github.com/Aohk22/fcj-project-1.git app
cd app
git switch webserver-ec2
cd app
nohup bun run index.ts >~/http.log 2>&1 &
EOF
