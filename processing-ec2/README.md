To run the server:
```
sudo apt install ssdeep
python -m venv <virtual_env_name>
source <virtual_env_name>/bin/activate
pip install -r requirements.txt
chmod +x ssdeep
fastapi dev --port 9090 --host 0.0.0.0 app.py
```
```
python -m uvicorn app:app --reload
```

Send sample requests to server through http://<host_ip>:9090/docs.  
Documentation: https://fastapi.tiangolo.com/features/.  

todo:
- yara, clamav

<sub>auth: ltk</sub>  
