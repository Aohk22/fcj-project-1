#!/bin/bash

apt update -y
apt install -y git unzip
snap install bun-js

su ubuntu
git clone https://github.com/Aohk22/fcj-project-1.git ~/app
cd ~/app
git switch webserver-ec2

cd app

nohup bun run index.ts >/var/log/http.log 2>&1 &
