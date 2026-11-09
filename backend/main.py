"""
backend/main.py
===================
FastAPI main application entrypoint for AquaIntel backend services.
Includes MongoDB database routes and AquaBot OpenRouter AI integration
with full chat persistence to MongoDB (chatbot_sessions + chatbot_messages).
"""

from datetime import datetime, timezone
from typing import List, Optional

from bson import ObjectId
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from ai_service import AquaBotAIService
from database import db

app = FastAPI(title="AquaIntel API", version="1.0.0")

# Enable CORS for Flutter app (Web, Android emulator, iOS simulator, desktop)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def _utcnow() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)


def _str_id(oid) -> str:
    return str(oid)


# ---------------------------------------------------------------------------
# Pydantic schemas
# ---------------------------------------------------------------------------

class ChatMessage(BaseModel):
    role: str
    content: str


class ChatRequest(BaseModel):
    message: str
    history: Optional[List[ChatMessage]] = []
    session_id: Optional[str] = None   # Pass existing session ID to continue a conversation
    user_id: Optional[str] = None       # Optional Firebase UID / user identifier


class ChatResponse(BaseModel):
    status: str
    reply: str
    session_id: str
    model_used: Optional[str] = None


# ---------------------------------------------------------------------------
# Routes
# ---------------------------------------------------------------------------

@app.get("/")
def home():
    return {
        "app": "AquaIntel API",
        "status": "online",
        "ai_configured": AquaBotAIService.is_configured(),
    }


@app.get("/database-test")
def database_test():
    try:
        db.command("ping")
        return {"status": "success", "message": "Connected to MongoDB"}
    except Exception as e:
        return {"status": "error", "message": str(e)}


@app.get("/api/chat/health")
def chat_health():
    return {
        "status": "ok",
        "ai_service": "AquaBot OpenRouter AI",
        "configured": AquaBotAIService.is_configured(),
    }


@app.post("/api/chat", response_model=ChatResponse)
async def chat_with_aquabot(request: ChatRequest):
    if not request.message or not request.message.strip():
        raise HTTPException(status_code=400, detail="Message prompt cannot be empty.")

    # ── 1. Resolve / create session ─────────────────────────────────────────
    now = _utcnow()

    if request.session_id:
        try:
            session_oid = ObjectId(request.session_id)
            session = db.chatbot_sessions.find_one({"_id": session_oid})
        except Exception:
            session = None
    else:
        session = None

    if session is None:
        # Create a new session document
        session_oid = ObjectId()
        session_doc = {
            "_id": session_oid,
            "user_id": request.user_id or "anonymous",
            "started_at": now,
            "updated_at": now,
            "total_messages": 0,
        }
        db.chatbot_sessions.insert_one(session_doc)

    session_id_str = _str_id(session_oid)

    # ── 2. Save user message ─────────────────────────────────────────────────
    user_msg_doc = {
        "_id": ObjectId(),
        "session_id": session_oid,
        "role": "user",
        "content": request.message.strip(),
        "sent_at": now,
        "is_domain_valid": True,   # Assume valid; AI itself enforces the domain guard
    }
    db.chatbot_messages.insert_one(user_msg_doc)

    # ── 3. Call AI ───────────────────────────────────────────────────────────
    history_list = [msg.model_dump() for msg in request.history] if request.history else []

    result = await AquaBotAIService.generate_response(
        user_message=request.message,
        chat_history=history_list,
    )

    reply_text: str = result.get("reply", "Sorry, I could not get a response.")
    ai_status: str = result.get("status", "error")
    model_used: str = result.get("model_used", "unknown")

    # ── 4. Save assistant reply ──────────────────────────────────────────────
    bot_msg_doc = {
        "_id": ObjectId(),
        "session_id": session_oid,
        "role": "assistant",
        "content": reply_text,
        "sent_at": _utcnow(),
        "is_domain_valid": ai_status == "success",
        "model_used": model_used,
    }
    db.chatbot_messages.insert_one(bot_msg_doc)

    # ── 5. Update session counters ───────────────────────────────────────────
    db.chatbot_sessions.update_one(
        {"_id": session_oid},
        {"$inc": {"total_messages": 2}, "$set": {"updated_at": _utcnow()}},
    )

    return ChatResponse(
        status=ai_status,
        reply=reply_text,
        session_id=session_id_str,
        model_used=model_used,
    )


@app.get("/api/chat/history/{session_id}")
def get_chat_history(session_id: str):
    """Returns all messages for a given session ID."""
    try:
        session_oid = ObjectId(session_id)
    except Exception:
        raise HTTPException(status_code=400, detail="Invalid session_id format.")

    messages = list(
        db.chatbot_messages.find(
            {"session_id": session_oid},
            {"_id": 0, "session_id": 0},
        ).sort("sent_at", 1)
    )
    # Convert datetime to ISO string for JSON serialisation
    for msg in messages:
        if isinstance(msg.get("sent_at"), datetime):
            msg["sent_at"] = msg["sent_at"].isoformat()

    return {"session_id": session_id, "messages": messages}


@app.get("/api/chat/sessions")
def list_sessions(user_id: Optional[str] = None):
    """Lists all chat sessions, optionally filtered by user_id."""
    query = {}
    if user_id:
        query["user_id"] = user_id

    sessions = list(
        db.chatbot_sessions.find(query, {"_id": 1, "user_id": 1, "started_at": 1, "total_messages": 1})
        .sort("started_at", -1)
        .limit(50)
    )
    for s in sessions:
        s["_id"] = str(s["_id"])
        if isinstance(s.get("started_at"), datetime):
            s["started_at"] = s["started_at"].isoformat()

    return {"sessions": sessions}