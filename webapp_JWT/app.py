from flask import Flask
from datetime import datetime, timezone

app = Flask(__name__)

@app.get("/time")
def time():
    return {"utc_time": datetime.now(timezone.utc).isoformat()}

if __name__ == "__main__":
    app.run()