#!/bin/bash

apt update -y
apt install -y git unzip
curl -fsSL https://bun.sh/install | bash
source /root/.bashrc

git clone https://github.com/Aohk22/fcj-project-1.git repo
cd repo/
git switch webserver-ec2
cp -r app /app

cd /app
nohup bun run index.ts >/var/log/http.log 2>&1 &
