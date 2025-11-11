#!/bin/bash

apt update -y
apt install -y git unzip
snap install bun-js
# curl -fsSL https://bun.sh/install | bash
source /root/.bashrc

git clone https://github.com/Aohk22/fcj-project-1.git /app
cd /app

git switch webserver-ec2

cd /app/app

nohup bun run index.ts >/var/log/http.log 2>&1 &
