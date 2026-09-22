from fastapi import FastAPI
from database import db

app = FastAPI(title="AquaIntel API")


@app.get("/")
def home():
    return {
        "message": "AquaIntel API is running"
    }


@app.get("/database-test")
def database_test():
    try:
        db.command("ping")

        return {
            "status": "success",
            "message": "Connected to MongoDB"
        }

    except Exception as e:
        return {
            "status": "error",
            "message": str(e)
        }