#!/bin/bash
set -e

sudo -u ubuntu bash <<'EOF'
set -e
cd /home/ubuntu/app
source .venv/bin/activate
nohup fastapi run --port 4100 --host 0.0.0.0 >/var/log/http.log 2>&1 &
EOF
