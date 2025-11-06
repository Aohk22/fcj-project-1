To run the server:
```
sudo apt install ssdeep python3 python3-venv python3-pip
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
fastapi dev --port 9090 --host 0.0.0.0 app.py
```

Send sample requests to server through `http://<host_ip>:9090/docs`.  
Documentation: `https://fastapi.tiangolo.com/features/`.  
