"""
backend/database.py
===================
MongoDB connection for AquaIntel.
Supports both:
  - MongoDB Atlas via MONGO_URI env variable (with certifi for TLS on Windows)
  - Local MongoDB (mongodb://localhost:27017) as fallback
"""

import os
import certifi
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()

# Read URI from environment or fall back to local MongoDB
MONGO_URI = os.getenv("MONGO_URI")

if not MONGO_URI:
    # .env file might store the URI without a key= prefix (plain URI on one line)
    env_path = os.path.join(os.path.dirname(__file__), ".env")
    if os.path.exists(env_path):
        with open(env_path, "r", encoding="utf-8") as _f:
            _raw = _f.read().strip()
        if _raw.startswith("mongodb"):
            MONGO_URI = _raw

LOCAL_URI = "mongodb://localhost:27017"

# Try Atlas first, fall back to local
def _build_client() -> MongoClient:
    if MONGO_URI and MONGO_URI != LOCAL_URI:
        try:
            _c = MongoClient(MONGO_URI, tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)
            _c.admin.command("ping")
            print("[AquaIntel] Connected to MongoDB Atlas")
            return _c
        except Exception as _e:
            print(f"[AquaIntel] Atlas unavailable ({_e.__class__.__name__}), falling back to localhost")

    _c = MongoClient(LOCAL_URI, serverSelectionTimeoutMS=5000)
    _c.admin.command("ping")
    print("[AquaIntel] Connected to local MongoDB (localhost:27017)")
    return _c


client: MongoClient = _build_client()
db = client["aquaintel"]
