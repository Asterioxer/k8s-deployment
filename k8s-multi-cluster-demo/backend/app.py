# backend/app.py
from flask import Flask, jsonify
import os
import datetime

app = Flask(__name__)

@app.route("/api/hello")
def hello():
    return jsonify({
        "message": "Hello from Backend!",
        "pod": os.environ.get("HOSTNAME"),
        "time": datetime.datetime.utcnow().isoformat() + "Z"
    })

@app.route("/api/write")
def write_file():
    # demo persistent write to /data (mounted PVC)
    try:
        os.makedirs("/data", exist_ok=True)
        fname = "/data/log.txt"
        with open(fname, "a") as f:
            f.write(f"{datetime.datetime.utcnow().isoformat()} - write from pod {os.environ.get('HOSTNAME')}\n")
        return jsonify({"status": "ok", "file": fname})
    except Exception as e:
        return jsonify({"status": "error", "err": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
