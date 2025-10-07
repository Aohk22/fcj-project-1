from flask import Flask, request, jsonify, send_from_directory
from flask_cors import CORS
import requests
import os

app = Flask(__name__)
CORS(app)
# change to backend server IP
FASTAPI_URL = "http://172.27.158.118:9090/get_static/"

@app.route("/")
def index():
    return send_from_directory(os.path.dirname(__file__), "index.html")

@app.route("/analyze", methods=["POST"])
def analyze_file():
    if 'raw_data' not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files['raw_data']
    try:
        response = requests.post(
            FASTAPI_URL,
            files={"raw_data": (file.filename, file.stream, file.mimetype)}
        )
        return jsonify(response.json()), response.status_code
    except requests.exceptions.RequestException as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
