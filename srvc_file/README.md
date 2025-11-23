# Quick Start

**Install:**

```bash
sudo apt install -y git ssdeep python3 python3-venv python3-pip unzip openjdk-21-jdk wget

wget https://github.com/NationalSecurityAgency/ghidra/releases/download/Ghidra_11.4.2_build/ghidra_11.4.2_PUBLIC_20250826.zip
sudo unzip ghidra_11.4.2_PUBLIC_20250826.zip -d /opt/

python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

**Run:**

```bash
# Creates a log file in home folder.
fastapi dev --port 4100 --host 0.0.0.0 >~/http.log 2>&1
```

Send sample requests to server through `http://localhost:4100/docs`.  
