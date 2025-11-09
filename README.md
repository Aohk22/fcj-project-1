To run the server:
```
sudo apt install -y ssdeep python3 python3-venv python3-pip
sudo apt install -y javasdk-21-jdk

wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.4.2_build/ghidra_11.4.2_PUBLIC_20250826.zip
sudo unzip ghidra_11.4.2_PUBLIC_20250826.zip -d /opt/ghidra_11.4.2_PUBLIC_20250826

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

fastapi dev --port <port> --host <host_ip> app.py
```

Send sample requests to server through `http://<host_ip>:<port>/docs`.  
Documentation: `https://fastapi.tiangolo.com/features/`.  
