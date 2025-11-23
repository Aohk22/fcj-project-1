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
git clone https://github.com/Aohk22/fcj-1-file-analyzer.git app
cd app/srvc_web/
# nohup bun run index.ts >~/http.log 2>&1 &
nohup ./run.sh > ~/http.log 2>&1 &
EOF
