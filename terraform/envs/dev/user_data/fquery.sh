#!/bin/bash
set -e

# Run query service as ubuntu user
sudo -u ubuntu bash <<'EOF'
set -e
cd /home/ubuntu/app
source .venv/bin/activate
nohup fastapi run --port 4101 --host 0.0.0.0 >~/http.log 2>&1 &
EOF
