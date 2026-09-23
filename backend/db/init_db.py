"""
backend/db/init_db.py
=====================
AquaIntel — MongoDB Core Schema Initialiser

Creates all 8 required collections in the `aquaintel` database with:
  - $jsonSchema validators (BSON type enforcement, required fields, enum values)
  - Targeted indexes for actual query patterns

Run once (or re-run safely — existing validators are replaced via collMod).

Usage:
    cd AquaIntel
    backend\\venv\\Scripts\\python.exe backend/db/init_db.py
"""

import sys
import os

# Ensure the backend package is importable
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from pymongo import ASCENDING, DESCENDING, IndexModel
from pymongo.errors import CollectionInvalid, OperationFailure
from database import db

print("\n" + "=" * 60)
print("  AquaIntel — MongoDB Schema Initialiser")
print("=" * 60)

# ---------------------------------------------------------------------------
# Helper
# ---------------------------------------------------------------------------

def create_or_update_collection(name: str, validator: dict):
    """Create collection with validator, or update validator if it already exists."""
    existing = db.list_collection_names()
    if name not in existing:
        db.create_collection(name, validator=validator, validationLevel="strict", validationAction="error")
        print(f"  [CREATED]  {name}")
    else:
        try:
            db.command("collMod", name, validator=validator, validationLevel="strict", validationAction="error")
            print(f"  [UPDATED]  {name}")
        except OperationFailure as e:
            print(f"  [ERROR]    Could not update validator for {name}: {e}")
            raise

# ---------------------------------------------------------------------------
# 1. USERS
# ---------------------------------------------------------------------------
create_or_update_collection("users", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["fullname", "email", "password_hash", "created_at"],
        "additionalProperties": True,
        "properties": {
            "_id":           {"bsonType": "objectId"},
            "fullname":      {"bsonType": "string",   "description": "User's full name"},
            "email":         {"bsonType": "string",   "description": "Unique email address"},
            "password_hash": {"bsonType": "string",   "description": "bcrypt password hash"},
            "phone_number":  {"bsonType": "string",   "description": "Optional contact number"},
            "created_at":    {"bsonType": "date",     "description": "Account creation timestamp"},
        }
    }
})

users_col = db["users"]
users_col.create_indexes([
    IndexModel([("email", ASCENDING)], unique=True, name="email_unique"),
])
print("    -> indexes: email (unique)")

# ---------------------------------------------------------------------------
# 2. AQUARIUMS
# ---------------------------------------------------------------------------
create_or_update_collection("aquariums", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["user_id", "tank_name", "tank_size_litres", "tank_type", "setup_date", "created_at"],
        "additionalProperties": True,
        "properties": {
            "_id":              {"bsonType": "objectId"},
            "user_id":          {"bsonType": "objectId", "description": "Reference to users._id"},
            "tank_name":        {"bsonType": "string"},
            "tank_size_litres": {"bsonType": "double",   "minimum": 0.1,
                                 "description": "Tank volume in litres"},
            "tank_type":        {"bsonType": "string",
                                 "enum": ["Freshwater", "Saltwater", "Brackish", "Planted", "Reef", "Coldwater"],
                                 "description": "Type of aquarium"},
            "setup_date":       {"bsonType": "date",    "description": "Date the tank was established"},
            "notes":            {"bsonType": "string",  "description": "Optional notes (equipment, substrate)"},
            "created_at":       {"bsonType": "date"},
        }
    }
})

aquariums_col = db["aquariums"]
aquariums_col.create_indexes([
    IndexModel([("user_id", ASCENDING)], name="aquariums_user_id"),
])
print("    -> indexes: user_id")

# ---------------------------------------------------------------------------
# 3. FISH
# ---------------------------------------------------------------------------
create_or_update_collection("fish", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["aquarium_id", "species_name", "common_name", "quantity", "health_status", "date_added"],
        "additionalProperties": True,
        "properties": {
            "_id":          {"bsonType": "objectId"},
            "aquarium_id":  {"bsonType": "objectId", "description": "Reference to aquariums._id"},
            "species_name": {"bsonType": "string",   "description": "Scientific/formal species name"},
            "common_name":  {"bsonType": "string",   "description": "Common name"},
            "quantity":     {"bsonType": "int",      "minimum": 1, "description": "Count of fish"},
            "health_status":{"bsonType": "string",
                             "enum": ["Healthy", "Sick", "Dead"],
                             "description": "Health state — drives dashboard colour coding"},
            "date_added":   {"bsonType": "date"},
            "notes":        {"bsonType": "string"},
        }
    }
})

fish_col = db["fish"]
fish_col.create_indexes([
    IndexModel([("aquarium_id", ASCENDING)], name="fish_aquarium_id"),
])
print("    -> indexes: aquarium_id")

# ---------------------------------------------------------------------------
# 4. WATER_QUALITY_LOGS
# ---------------------------------------------------------------------------
create_or_update_collection("water_quality_logs", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["aquarium_id", "ph_level", "temperature_c", "recorded_at"],
        "additionalProperties": True,
        "properties": {
            "_id":           {"bsonType": "objectId"},
            "aquarium_id":   {"bsonType": "objectId", "description": "Reference to aquariums._id"},
            "ph_level":      {"bsonType": "double",   "minimum": 0.0, "maximum": 14.0,
                              "description": "Water pH (0–14)"},
            "temperature_c": {"bsonType": "double",   "minimum": 0.0, "maximum": 60.0,
                              "description": "Temperature in Celsius"},
            "ammonia_ppm":   {"bsonType": "double",   "minimum": 0.0,
                              "description": "Ammonia concentration in ppm"},
            "nitrate_ppm":   {"bsonType": "double",   "minimum": 0.0,
                              "description": "Nitrate concentration in ppm"},
            "recorded_at":   {"bsonType": "date",     "description": "Test timestamp"},
        }
    }
})

wq_col = db["water_quality_logs"]
wq_col.create_indexes([
    IndexModel([("aquarium_id", ASCENDING), ("recorded_at", DESCENDING)],
               name="wq_aquarium_date"),
])
print("    -> indexes: (aquarium_id, recorded_at DESC) - supports 30-day trend chart")

# ---------------------------------------------------------------------------
# 5. REMINDERS
# ---------------------------------------------------------------------------
create_or_update_collection("reminders", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["user_id", "aquarium_id", "reminder_type", "scheduled_at",
                     "is_completed", "is_sent", "is_recurring", "created_at"],
        "additionalProperties": True,
        "properties": {
            "_id":           {"bsonType": "objectId"},
            "user_id":       {"bsonType": "objectId", "description": "Reference to users._id"},
            "aquarium_id":   {"bsonType": "objectId", "description": "Reference to aquariums._id"},
            "reminder_type": {"bsonType": "string",
                              "enum": ["Feeding", "Water Change", "Filter Cleaning",
                                       "Water Testing", "Tank Cleaning", "Medication", "Other"],
                              "description": "Category of maintenance task"},
            "scheduled_at":  {"bsonType": "date",    "description": "When the reminder is due"},
            "is_completed":  {"bsonType": "bool",    "description": "True after user completes the task"},
            "is_sent":       {"bsonType": "bool",    "description": "True after push notification fired"},
            "is_recurring":  {"bsonType": "bool",    "description": "True for repeating reminders"},
            "interval_days": {"bsonType": "int",     "minimum": 1,
                              "description": "Repeat interval in days (required when is_recurring=true)"},
            "created_at":    {"bsonType": "date"},
        }
    }
})

reminders_col = db["reminders"]
reminders_col.create_indexes([
    IndexModel([("user_id", ASCENDING), ("is_completed", ASCENDING), ("scheduled_at", ASCENDING)],
               name="reminders_pending"),
    IndexModel([("aquarium_id", ASCENDING)], name="reminders_aquarium_id"),
])
print("    -> indexes: (user_id, is_completed, scheduled_at), aquarium_id")

# ---------------------------------------------------------------------------
# 6. MAINTENANCE_LOGS
# ---------------------------------------------------------------------------
create_or_update_collection("maintenance_logs", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["aquarium_id", "task_type", "completed_at"],
        "additionalProperties": True,
        "properties": {
            "_id":          {"bsonType": "objectId"},
            "aquarium_id":  {"bsonType": "objectId", "description": "Reference to aquariums._id"},
            "reminder_id":  {"bsonType": ["objectId", "null"],
                             "description": "Reference to reminders._id (null for manual entries)"},
            "task_type":    {"bsonType": "string",
                             "enum": ["Feeding", "Water Change", "Filter Cleaning",
                                      "Water Testing", "Tank Cleaning", "Medication", "Other"],
                             "description": "Type of maintenance performed"},
            "completed_at": {"bsonType": "date", "description": "Completion timestamp"},
            "notes":        {"bsonType": "string", "description": "Optional notes about the task"},
        }
    }
})

ml_col = db["maintenance_logs"]
ml_col.create_indexes([
    IndexModel([("aquarium_id", ASCENDING), ("completed_at", DESCENDING)],
               name="ml_aquarium_date"),
    IndexModel([("reminder_id", ASCENDING)], sparse=True, name="ml_reminder_id"),
])
print("    -> indexes: (aquarium_id, completed_at DESC), reminder_id (sparse)")

# ---------------------------------------------------------------------------
# 7. CHATBOT_SESSIONS
# ---------------------------------------------------------------------------
create_or_update_collection("chatbot_sessions", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["user_id", "started_at", "total_messages", "updated_at"],
        "additionalProperties": True,
        "properties": {
            "_id":            {"bsonType": "objectId"},
            "user_id":        {"bsonType": "objectId", "description": "Reference to users._id"},
            "started_at":     {"bsonType": "date",     "description": "Session start timestamp"},
            "total_messages": {"bsonType": "int",      "minimum": 0,
                               "description": "Message count for API rate limiting"},
            "updated_at":     {"bsonType": "date",     "description": "Timestamp of last message"},
        }
    }
})

cs_col = db["chatbot_sessions"]
cs_col.create_indexes([
    IndexModel([("user_id", ASCENDING), ("updated_at", DESCENDING)],
               name="cs_user_updated"),
])
print("    -> indexes: (user_id, updated_at DESC)")

# ---------------------------------------------------------------------------
# 8. CHATBOT_MESSAGES
# ---------------------------------------------------------------------------
create_or_update_collection("chatbot_messages", {
    "$jsonSchema": {
        "bsonType": "object",
        "required": ["session_id", "role", "content", "sent_at", "is_domain_valid"],
        "additionalProperties": True,
        "properties": {
            "_id":             {"bsonType": "objectId"},
            "session_id":      {"bsonType": "objectId", "description": "Reference to chatbot_sessions._id"},
            "role":            {"bsonType": "string",
                                "enum": ["user", "assistant", "system"],
                                "description": "Message author role"},
            "content":         {"bsonType": "string",   "description": "Text content of the message"},
            "sent_at":         {"bsonType": "date",     "description": "Message timestamp"},
            "is_domain_valid": {"bsonType": "bool",
                                "description": "True=aquarium query; False=rejected by domain filter"},
        }
    }
})

cm_col = db["chatbot_messages"]
cm_col.create_indexes([
    IndexModel([("session_id", ASCENDING), ("sent_at", ASCENDING)],
               name="cm_session_time"),
])
print("    -> indexes: (session_id, sent_at ASC) - chronological conversation stream")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
all_collections = db.list_collection_names()
print("\n" + "=" * 60)
print(f"  Collections in aquaintel db: {sorted(all_collections)}")
print("  Schema initialisation COMPLETE [OK]")
print("=" * 60 + "\n")
