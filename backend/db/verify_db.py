"""
backend/db/verify_db.py
=======================
AquaIntel — Database Verification Script

Performs a complete automated verification:
  1. All 8 required collections exist
  2. Valid sample documents are present
  3. Schema validators reject invalid documents
  4. Indexes exist as expected
  5. ObjectId references are referentially consistent

Exit code 0 = all checks passed
Exit code 1 = one or more checks failed

Usage:
    cd AquaIntel
    backend\\venv\\Scripts\\python.exe backend/db/verify_db.py
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from datetime import datetime, timezone
from bson import ObjectId
from pymongo.errors import WriteError
from database import db

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

PASS = "  [PASS]"
FAIL = "  [FAIL]"
INFO = "  [INFO]"

failures = []

def check(label: str, result: bool, detail: str = ""):
    if result:
        print(f"{PASS} {label}")
    else:
        print(f"{FAIL} {label}" + (f" -> {detail}" if detail else ""))
        failures.append(label)

def utcnow():
    return datetime.now(timezone.utc).replace(tzinfo=None)

print("\n" + "=" * 60)
print("  AquaIntel — Database Verification")
print("=" * 60 + "\n")

# ---------------------------------------------------------------------------
# CHECK 1: All 8 collections exist
# ---------------------------------------------------------------------------
print("-- 1. Collection Existence ----------------------------------")
REQUIRED_COLLECTIONS = [
    "users", "aquariums", "fish", "water_quality_logs",
    "reminders", "maintenance_logs", "chatbot_sessions", "chatbot_messages"
]
existing = set(db.list_collection_names())
for col in REQUIRED_COLLECTIONS:
    check(f"Collection '{col}' exists", col in existing)

# ---------------------------------------------------------------------------
# CHECK 2: Sample documents exist in each collection
# ---------------------------------------------------------------------------
print("\n-- 2. Sample Documents --------------------------------------")
for col in REQUIRED_COLLECTIONS:
    count = db[col].count_documents({})
    check(f"'{col}' has at least 1 document (found {count})", count >= 1)

# ---------------------------------------------------------------------------
# CHECK 3: Required fields present in sample documents
# ---------------------------------------------------------------------------
print("\n-- 3. Schema Field Presence ---------------------------------")

user = db.users.find_one()
if user:
    for field in ["fullname", "email", "password_hash", "created_at"]:
        check(f"users.{field} present", field in user)
    check("users.created_at is datetime", isinstance(user.get("created_at"), datetime))

aq = db.aquariums.find_one()
if aq:
    for field in ["user_id", "tank_name", "tank_size_litres", "tank_type", "setup_date"]:
        check(f"aquariums.{field} present", field in aq)
    check("aquariums.user_id is ObjectId", isinstance(aq.get("user_id"), ObjectId))
    check("aquariums.tank_size_litres is float", isinstance(aq.get("tank_size_litres"), float))
    check("aquariums.setup_date is datetime", isinstance(aq.get("setup_date"), datetime))

fish = db.fish.find_one()
if fish:
    check("fish.health_status is Healthy/Sick/Dead",
          fish.get("health_status") in ["Healthy", "Sick", "Dead"])
    check("fish.quantity is int", isinstance(fish.get("quantity"), int))
    check("fish.aquarium_id is ObjectId", isinstance(fish.get("aquarium_id"), ObjectId))

wq = db.water_quality_logs.find_one()
if wq:
    check("water_quality_logs.ph_level is float", isinstance(wq.get("ph_level"), float))
    check("water_quality_logs.recorded_at is datetime", isinstance(wq.get("recorded_at"), datetime))

reminder = db.reminders.find_one()
if reminder:
    check("reminders.is_completed is bool", isinstance(reminder.get("is_completed"), bool))
    check("reminders.is_sent is bool", isinstance(reminder.get("is_sent"), bool))
    check("reminders.is_recurring is bool", isinstance(reminder.get("is_recurring"), bool))
    check("reminders.scheduled_at is datetime", isinstance(reminder.get("scheduled_at"), datetime))

ml = db.maintenance_logs.find_one()
if ml:
    check("maintenance_logs.task_type present", "task_type" in ml)
    check("maintenance_logs.completed_at is datetime", isinstance(ml.get("completed_at"), datetime))

session = db.chatbot_sessions.find_one()
if session:
    check("chatbot_sessions.total_messages is int", isinstance(session.get("total_messages"), int))
    check("chatbot_sessions.user_id is ObjectId", isinstance(session.get("user_id"), ObjectId))

msg = db.chatbot_messages.find_one()
if msg:
    check("chatbot_messages.is_domain_valid is bool", isinstance(msg.get("is_domain_valid"), bool))
    check("chatbot_messages.role is user/assistant/system",
          msg.get("role") in ["user", "assistant", "system"])
    check("chatbot_messages.session_id is ObjectId", isinstance(msg.get("session_id"), ObjectId))

# ---------------------------------------------------------------------------
# CHECK 4: Validators reject invalid documents
# ---------------------------------------------------------------------------
print("\n-- 4. Validator Rejection Tests -----------------------------")

# 4a: Insert user without required 'email' field -> must fail
try:
    db.users.insert_one({
        "_id": ObjectId(),
        "fullname": "Bad User",
        "password_hash": "$2b$12$dummy",
        "created_at": utcnow(),
        # email intentionally missing
    })
    check("Reject user without email", False, "No WriteError raised — validation not enforced!")
except WriteError:
    check("Reject user without email (email missing)", True)

# 4b: Insert fish with invalid health_status -> must fail
try:
    aq = db.aquariums.find_one()
    db.fish.insert_one({
        "_id": ObjectId(),
        "aquarium_id": aq["_id"] if aq else ObjectId(),
        "species_name": "Testus fishus",
        "common_name": "Test Fish",
        "quantity": 1,
        "health_status": "Unknown",  # not in enum
        "date_added": utcnow(),
    })
    check("Reject fish with invalid health_status 'Unknown'", False, "No WriteError raised!")
except WriteError:
    check("Reject fish with invalid health_status 'Unknown'", True)

# 4c: Insert water_quality_log with ph_level out of range -> must fail
try:
    aq = db.aquariums.find_one()
    db.water_quality_logs.insert_one({
        "_id": ObjectId(),
        "aquarium_id": aq["_id"] if aq else ObjectId(),
        "ph_level": 15.5,  # > 14.0, out of range
        "temperature_c": 25.0,
        "recorded_at": utcnow(),
    })
    check("Reject water_quality_logs with ph_level=15.5 (>14)", False, "No WriteError raised!")
except WriteError:
    check("Reject water_quality_logs with ph_level=15.5 (>14)", True)

# 4d: Insert chatbot_message with invalid role -> must fail
try:
    session = db.chatbot_sessions.find_one()
    db.chatbot_messages.insert_one({
        "_id": ObjectId(),
        "session_id": session["_id"] if session else ObjectId(),
        "role": "bot",  # not in enum ["user", "assistant", "system"]
        "content": "Invalid role test",
        "sent_at": utcnow(),
        "is_domain_valid": True,
    })
    check("Reject chatbot_messages with role='bot'", False, "No WriteError raised!")
except WriteError:
    check("Reject chatbot_messages with role='bot'", True)

# 4e: Insert fish with quantity=0 (fish) -> must fail
try:
    aq = db.aquariums.find_one()
    db.fish.insert_one({
        "_id": ObjectId(),
        "aquarium_id": aq["_id"] if aq else ObjectId(),
        "species_name": "Testus zero",
        "common_name": "Zero Fish",
        "quantity": 0,  # minimum is 1
        "health_status": "Healthy",
        "date_added": utcnow(),
    })
    check("Reject fish with quantity=0 (minimum=1)", False, "No WriteError raised!")
except WriteError:
    check("Reject fish with quantity=0 (minimum=1)", True)

# ---------------------------------------------------------------------------
# CHECK 5: Indexes exist
# ---------------------------------------------------------------------------
print("\n-- 5. Index Verification ------------------------------------")

def get_index_names(col_name: str) -> list:
    return [idx["name"] for idx in db[col_name].list_indexes()]

check("users: email_unique index exists",
      "email_unique" in get_index_names("users"))
check("aquariums: aquariums_user_id index exists",
      "aquariums_user_id" in get_index_names("aquariums"))
check("fish: fish_aquarium_id index exists",
      "fish_aquarium_id" in get_index_names("fish"))
check("water_quality_logs: wq_aquarium_date index exists",
      "wq_aquarium_date" in get_index_names("water_quality_logs"))
check("reminders: reminders_pending index exists",
      "reminders_pending" in get_index_names("reminders"))
check("maintenance_logs: ml_aquarium_date index exists",
      "ml_aquarium_date" in get_index_names("maintenance_logs"))
check("chatbot_sessions: cs_user_updated index exists",
      "cs_user_updated" in get_index_names("chatbot_sessions"))
check("chatbot_messages: cm_session_time index exists",
      "cm_session_time" in get_index_names("chatbot_messages"))

# ---------------------------------------------------------------------------
# CHECK 6: Unique index enforcement (duplicate email rejected)
# ---------------------------------------------------------------------------
print("\n-- 6. Unique Index Enforcement ------------------------------")
from pymongo.errors import DuplicateKeyError
existing_user = db.users.find_one()
if existing_user:
    try:
        db.users.insert_one({
            "_id": ObjectId(),
            "fullname": "Duplicate Email User",
            "email": existing_user["email"],  # duplicate
            "password_hash": "$2b$12$dummy",
            "created_at": utcnow(),
        })
        check("Reject duplicate email (unique index)", False, "No DuplicateKeyError raised!")
    except DuplicateKeyError:
        check("Reject duplicate email (unique index)", True)

# ---------------------------------------------------------------------------
# CHECK 7: ObjectId referential consistency
# ---------------------------------------------------------------------------
print("\n-- 7. Referential Consistency -------------------------------")

all_user_ids = {d["_id"] for d in db.users.find({}, {"_id": 1})}
all_aquarium_ids = {d["_id"] for d in db.aquariums.find({}, {"_id": 1})}
all_reminder_ids = {d["_id"] for d in db.reminders.find({}, {"_id": 1})}
all_session_ids = {d["_id"] for d in db.chatbot_sessions.find({}, {"_id": 1})}

# All aquariums.user_id must exist in users
dangling_aq = [a for a in db.aquariums.find() if a["user_id"] not in all_user_ids]
check("All aquariums.user_id reference valid users", len(dangling_aq) == 0,
      f"{len(dangling_aq)} dangling reference(s)")

# All fish.aquarium_id must exist in aquariums
dangling_fish = [f for f in db.fish.find() if f["aquarium_id"] not in all_aquarium_ids]
check("All fish.aquarium_id reference valid aquariums", len(dangling_fish) == 0,
      f"{len(dangling_fish)} dangling reference(s)")

# All water_quality_logs.aquarium_id must exist in aquariums
dangling_wq = [w for w in db.water_quality_logs.find() if w["aquarium_id"] not in all_aquarium_ids]
check("All water_quality_logs.aquarium_id reference valid aquariums", len(dangling_wq) == 0,
      f"{len(dangling_wq)} dangling reference(s)")

# All reminders.user_id must exist in users
dangling_rem_user = [r for r in db.reminders.find() if r["user_id"] not in all_user_ids]
check("All reminders.user_id reference valid users", len(dangling_rem_user) == 0,
      f"{len(dangling_rem_user)} dangling reference(s)")

# All maintenance_logs.aquarium_id must exist in aquariums
dangling_ml = [m for m in db.maintenance_logs.find() if m["aquarium_id"] not in all_aquarium_ids]
check("All maintenance_logs.aquarium_id reference valid aquariums", len(dangling_ml) == 0,
      f"{len(dangling_ml)} dangling reference(s)")

# Maintenance_logs.reminder_id (when not None) must reference valid reminders
dangling_ml_rem = [
    m for m in db.maintenance_logs.find()
    if m.get("reminder_id") is not None and m["reminder_id"] not in all_reminder_ids
]
check("All maintenance_logs.reminder_id reference valid reminders (non-null)",
      len(dangling_ml_rem) == 0, f"{len(dangling_ml_rem)} dangling reference(s)")

# All chatbot_messages.session_id must exist in chatbot_sessions
dangling_msg = [m for m in db.chatbot_messages.find() if m["session_id"] not in all_session_ids]
check("All chatbot_messages.session_id reference valid sessions", len(dangling_msg) == 0,
      f"{len(dangling_msg)} dangling reference(s)")

# ---------------------------------------------------------------------------
# CHECK 8: Domain filter — both valid and invalid messages exist
# ---------------------------------------------------------------------------
print("\n-- 8. Domain Filter Data Integrity --------------------------")
valid_msgs = db.chatbot_messages.count_documents({"is_domain_valid": True})
invalid_msgs = db.chatbot_messages.count_documents({"is_domain_valid": False})
check(f"Domain-valid messages exist (found {valid_msgs})", valid_msgs >= 1)
check(f"Domain-invalid (filtered) messages exist (found {invalid_msgs})", invalid_msgs >= 1)

# ---------------------------------------------------------------------------
# Final Result
# ---------------------------------------------------------------------------
print("\n" + "=" * 60)
if not failures:
    print("  [SUCCESS] All verification checks PASSED")
else:
    print(f"  [ERROR] {len(failures)} check(s) FAILED:")
    for f in failures:
        print(f"       - {f}")
print("=" * 60 + "\n")
sys.exit(0 if not failures else 1)
