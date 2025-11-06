#!/bin/bash

apt update -y
apt install -y git python3 python3-venv python3-pip

mkdir /app
cd /app
git clone https://github.com/Aohk22/fcj-project-1.git
cd fcj-project-1
git switch webserver-ec2
python3 -m venv .venv
source .venv/bin/activate
pip install flask flask-cors requests
nohup python3 server.py >/var/log/http.log 2>&1 &
