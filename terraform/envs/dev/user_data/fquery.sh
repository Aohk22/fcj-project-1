#!/bin/bash

cd /app
source .venv/bin/activate
nohup fastapi run --port 4101 --host 0.0.0.0 >/var/log/http.log 2>&1 &
