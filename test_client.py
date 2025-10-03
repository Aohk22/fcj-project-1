#!/usr/bin/env python

import requests

def test_health():
    with open('pe_exec.exe', 'rb') as f:
        res = requests.post('http://localhost:6969/get_static/', files={'raw_data': f})
        print(res.text)
        print(res.status_code)
        assert res.status_code == 200
