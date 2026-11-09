"""
backend/database.py
===================
MongoDB connection manager for AquaIntel (SOLID Principles: SRP & DIP).
Supports both:
  - MongoDB Atlas via MONGO_URI env variable (with certifi for TLS on Windows)
  - Local MongoDB (mongodb://localhost:27017) as fallback
"""

import os
import certifi
from dotenv import load_dotenv
from pymongo import MongoClient

load_dotenv()


class DatabaseManager:
    """Encapsulates database connection lifecycle and client creation (SRP)."""

    def __init__(self, uri: str = None, local_fallback: str = "mongodb://localhost:27017"):
        self.uri = uri or os.getenv("MONGO_URI") or self._read_env_fallback()
        self.local_fallback = local_fallback
        self._client = None
        self._db = None

    def _read_env_fallback(self) -> str:
        env_path = os.path.join(os.path.dirname(__file__), ".env")
        if os.path.exists(env_path):
            try:
                with open(env_path, "r", encoding="utf-8") as f:
                    raw = f.read().strip()
                if raw.startswith("mongodb"):
                    return raw
            except Exception:
                pass
        return ""

    def get_client(self) -> MongoClient:
        if self._client:
            return self._client

        if self.uri and self.uri != self.local_fallback:
            try:
                c = MongoClient(self.uri, tlsCAFile=certifi.where(), serverSelectionTimeoutMS=5000)
                c.admin.command("ping")
                print("[AquaIntel] Connected to MongoDB Atlas")
                self._client = c
                return c
            except Exception as e:
                print(f"[AquaIntel] Atlas unavailable ({e.__class__.__name__}), falling back to localhost")

        c = MongoClient(self.local_fallback, serverSelectionTimeoutMS=5000)
        c.admin.command("ping")
        print("[AquaIntel] Connected to local MongoDB (localhost:27017)")
        self._client = c
        return c

    def get_database(self, db_name: str = "aquaintel"):
        if not self._db:
            client = self.get_client()
            self._db = client[db_name]
        return self._db


# Singleton instance
db_manager = DatabaseManager()
client: MongoClient = db_manager.get_client()
db = db_manager.get_database()
