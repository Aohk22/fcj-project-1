from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import requests
import os
import hashlib
from io import BytesIO

app = Flask(__name__)
CORS(app)

PROCESSING_URL = "http://services.system.internal/process/"
QUERY_URL = "http://services.system.internal/"

@app.route("/")
def index():
    return send_from_directory(os.path.dirname(__file__), "index.html")

@app.route("/analyze", methods=["POST"])
def analyze_file():
    if 'raw_data' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files['raw_data']
    file_bytes = file.read()
    file_hash = hashlib.sha256(file_bytes).hexdigest()
    try:
        query_response = requests.get(QUERY_URL, params={"file_hash": file_hash})
        if query_response.status_code == 200:
            return jsonify(query_response.json()), 200
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Query Service unreachable: {e}")
    try:
        file_stream = BytesIO(file_bytes)
        response = requests.post(
            PROCESSING_URL,
            files={"raw_data": (file.filename, file_stream, file.mimetype)}
        )
        return jsonify(response.json()), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80, debug=False)
