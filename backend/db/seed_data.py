"""
backend/db/seed_data.py
=======================
AquaIntel â€” Realistic Sample Data Seeder

Inserts a small, coherent set of test documents that:
  - Follow the finalised schema exactly
  - Use correct BSON types (ObjectId, Date, int, double, bool)
  - Demonstrate all ObjectId relationships
  - Cover both domain-valid and domain-invalid chatbot messages
  - Cover both reminder-triggered and manual maintenance logs

Seeding is idempotent: running twice will skip users that already exist
by email, and skip aquariums that already belong to that user.

Usage:
    cd AquaIntel
    backend\\venv\\Scripts\\python.exe backend/db/seed_data.py
"""

import sys
import os
sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from datetime import datetime, timedelta, timezone
from bson import ObjectId
from database import db

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def utcnow() -> datetime:
    return datetime.now(timezone.utc).replace(tzinfo=None)  # naive UTC for MongoDB

def days_ago(n: int) -> datetime:
    return utcnow() - timedelta(days=n)

def days_ahead(n: int) -> datetime:
    return utcnow() + timedelta(days=n)

print("\n" + "=" * 60)
print("  AquaIntel â€” Sample Data Seeder")
print("=" * 60)

# ---------------------------------------------------------------------------
# 1. USER
# ---------------------------------------------------------------------------
existing_user = db.users.find_one({"email": "amogh@aquaintel.dev"})
if existing_user:
    user_id = existing_user["_id"]
    print(f"  [SKIP]   User already exists (_id={user_id})")
else:
    user_doc = {
        "_id": ObjectId(),
        "fullname": "Amogh Shakya",
        "email": "amogh@aquaintel.dev",
        # bcrypt hash of "Demo@Pass1" (safe placeholder â€” never a real credential)
        "password_hash": "$2b$12$ExampleBcryptHashForDemoOnlyDoNotUseInProduction123456",
        "phone_number": "+977-9800000001",
        "created_at": days_ago(60),
    }
    db.users.insert_one(user_doc)
    user_id = user_doc["_id"]
    print(f"  [INSERT] User: Amogh Shakya (_id={user_id})")

# ---------------------------------------------------------------------------
# 2. AQUARIUMS (2)
# ---------------------------------------------------------------------------
existing_aquariums = list(db.aquariums.find({"user_id": user_id}))
aq_ids = [a["_id"] for a in existing_aquariums]

if len(existing_aquariums) >= 2:
    aq1_id, aq2_id = aq_ids[0], aq_ids[1]
    print(f"  [SKIP]   Aquariums already exist")
else:
    aq1_doc = {
        "_id": ObjectId(),
        "user_id": user_id,
        "tank_name": "Living Room Planted Tank",
        "tank_size_litres": 120.0,
        "tank_type": "Planted",
        "setup_date": days_ago(90),
        "notes": "Fluval 307 canister filter; CO2 injection; Seachem Flourite substrate",
        "created_at": days_ago(90),
    }
    aq2_doc = {
        "_id": ObjectId(),
        "user_id": user_id,
        "tank_name": "Office Marine Nano",
        "tank_size_litres": 60.0,
        "tank_type": "Saltwater",
        "setup_date": days_ago(45),
        "notes": "Hydor Koralia powerhead; Reef Octopus skimmer; live rock",
        "created_at": days_ago(45),
    }
    db.aquariums.insert_many([aq1_doc, aq2_doc])
    aq1_id, aq2_id = aq1_doc["_id"], aq2_doc["_id"]
    print(f"  [INSERT] Aquarium 1: Living Room Planted Tank (_id={aq1_id})")
    print(f"  [INSERT] Aquarium 2: Office Marine Nano (_id={aq2_id})")

# ---------------------------------------------------------------------------
# 3. FISH
# ---------------------------------------------------------------------------
if db.fish.count_documents({"aquarium_id": aq1_id}) == 0:
    fish_docs = [
        {
            "_id": ObjectId(),
            "aquarium_id": aq1_id,
            "species_name": "Paracheirodon innesi",
            "common_name": "Neon Tetra",
            "quantity": 12,
            "health_status": "Healthy",
            "date_added": days_ago(85),
            "notes": "Schooling fish; prefer dimly lit areas",
        },
        {
            "_id": ObjectId(),
            "aquarium_id": aq1_id,
            "species_name": "Trichogaster trichopterus",
            "common_name": "Three-Spot Gourami",
            "quantity": 3,
            "health_status": "Healthy",
            "date_added": days_ago(80),
            "notes": None,
        },
        {
            "_id": ObjectId(),
            "aquarium_id": aq1_id,
            "species_name": "Otocinclus affinis",
            "common_name": "Otocinclus Catfish",
            "quantity": 5,
            "health_status": "Sick",
            "date_added": days_ago(70),
            "notes": "Monitoring for white spot; quarantine recommended",
        },
    ]
    # Remove None notes before insert (optional field)
    for f in fish_docs:
        if f.get("notes") is None:
            del f["notes"]
    db.fish.insert_many(fish_docs)
    print(f"  [INSERT] 3 fish records for Aquarium 1")

if db.fish.count_documents({"aquarium_id": aq2_id}) == 0:
    marine_fish = [
        {
            "_id": ObjectId(),
            "aquarium_id": aq2_id,
            "species_name": "Amphiprion ocellaris",
            "common_name": "Clownfish",
            "quantity": 2,
            "health_status": "Healthy",
            "date_added": days_ago(40),
            "notes": "Pair; hosting in hammer coral",
        },
        {
            "_id": ObjectId(),
            "aquarium_id": aq2_id,
            "species_name": "Chromis viridis",
            "common_name": "Blue-Green Chromis",
            "quantity": 4,
            "health_status": "Healthy",
            "date_added": days_ago(38),
        },
    ]
    db.fish.insert_many(marine_fish)
    print(f"  [INSERT] 2 fish records for Aquarium 2")

# ---------------------------------------------------------------------------
# 4. WATER QUALITY LOGS (historical readings over 30 days)
# ---------------------------------------------------------------------------
if db.water_quality_logs.count_documents({"aquarium_id": aq1_id}) == 0:
    wq_aq1 = [
        {"_id": ObjectId(), "aquarium_id": aq1_id, "ph_level": 7.2, "temperature_c": 26.5,
         "ammonia_ppm": 0.0, "nitrate_ppm": 5.0,  "recorded_at": days_ago(30)},
        {"_id": ObjectId(), "aquarium_id": aq1_id, "ph_level": 7.0, "temperature_c": 26.8,
         "ammonia_ppm": 0.0, "nitrate_ppm": 8.0,  "recorded_at": days_ago(20)},
        {"_id": ObjectId(), "aquarium_id": aq1_id, "ph_level": 6.9, "temperature_c": 27.0,
         "ammonia_ppm": 0.1, "nitrate_ppm": 12.0, "recorded_at": days_ago(10)},
        {"_id": ObjectId(), "aquarium_id": aq1_id, "ph_level": 7.1, "temperature_c": 26.5,
         "ammonia_ppm": 0.0, "nitrate_ppm": 6.0,  "recorded_at": days_ago(1)},
    ]
    db.water_quality_logs.insert_many(wq_aq1)
    print(f"  [INSERT] 4 water quality logs for Aquarium 1 (30-day pH trend data)")

if db.water_quality_logs.count_documents({"aquarium_id": aq2_id}) == 0:
    wq_aq2 = [
        {"_id": ObjectId(), "aquarium_id": aq2_id, "ph_level": 8.2, "temperature_c": 25.5,
         "ammonia_ppm": 0.0, "nitrate_ppm": 3.0, "recorded_at": days_ago(15)},
        {"_id": ObjectId(), "aquarium_id": aq2_id, "ph_level": 8.3, "temperature_c": 25.0,
         "ammonia_ppm": 0.0, "nitrate_ppm": 2.5, "recorded_at": days_ago(5)},
    ]
    db.water_quality_logs.insert_many(wq_aq2)
    print(f"  [INSERT] 2 water quality logs for Aquarium 2")

# ---------------------------------------------------------------------------
# 5. REMINDERS (mix of pending, completed, recurring)
# ---------------------------------------------------------------------------
if db.reminders.count_documents({"aquarium_id": aq1_id}) == 0:
    reminder1_id = ObjectId()
    reminder2_id = ObjectId()
    reminder3_id = ObjectId()
    reminder_docs = [
        # Completed feeding reminder
        {
            "_id": reminder1_id,
            "user_id": user_id,
            "aquarium_id": aq1_id,
            "reminder_type": "Feeding",
            "scheduled_at": days_ago(3),
            "is_completed": True,
            "is_sent": True,
            "is_recurring": True,
            "interval_days": 1,
            "created_at": days_ago(90),
        },
        # Pending water change
        {
            "_id": reminder2_id,
            "user_id": user_id,
            "aquarium_id": aq1_id,
            "reminder_type": "Water Change",
            "scheduled_at": days_ahead(2),
            "is_completed": False,
            "is_sent": False,
            "is_recurring": True,
            "interval_days": 14,
            "created_at": days_ago(30),
        },
        # Pending filter cleaning
        {
            "_id": reminder3_id,
            "user_id": user_id,
            "aquarium_id": aq1_id,
            "reminder_type": "Filter Cleaning",
            "scheduled_at": days_ahead(7),
            "is_completed": False,
            "is_sent": False,
            "is_recurring": True,
            "interval_days": 30,
            "created_at": days_ago(30),
        },
    ]
    db.reminders.insert_many(reminder_docs)
    print(f"  [INSERT] 3 reminders for Aquarium 1")
else:
    # Get existing reminder IDs for maintenance log reference
    existing_reminders = list(db.reminders.find({"aquarium_id": aq1_id, "is_completed": True}))
    reminder1_id = existing_reminders[0]["_id"] if existing_reminders else None

if db.reminders.count_documents({"aquarium_id": aq2_id}) == 0:
    reminder4_id = ObjectId()
    reminder_doc2 = {
        "_id": reminder4_id,
        "user_id": user_id,
        "aquarium_id": aq2_id,
        "reminder_type": "Water Testing",
        "scheduled_at": days_ahead(1),
        "is_completed": False,
        "is_sent": False,
        "is_recurring": True,
        "interval_days": 7,
        "created_at": days_ago(45),
    }
    db.reminders.insert_one(reminder_doc2)
    print(f"  [INSERT] 1 reminder for Aquarium 2")

# ---------------------------------------------------------------------------
# 6. MAINTENANCE LOGS
# ---------------------------------------------------------------------------
if db.maintenance_logs.count_documents({"aquarium_id": aq1_id}) == 0:
    # One auto-generated from completed reminder
    completed_reminder = db.reminders.find_one({"aquarium_id": aq1_id, "is_completed": True})
    maintenance_docs = [
        {
            "_id": ObjectId(),
            "aquarium_id": aq1_id,
            "reminder_id": completed_reminder["_id"] if completed_reminder else None,
            "task_type": "Feeding",
            "completed_at": days_ago(3),
            "notes": "Fed 2 pinches of tropical flakes",
        },
        # Manual entry (no reminder_id)
        {
            "_id": ObjectId(),
            "aquarium_id": aq1_id,
            "reminder_id": None,
            "task_type": "Tank Cleaning",
            "completed_at": days_ago(7),
            "notes": "Scrubbed algae from front glass; vacuumed substrate",
        },
    ]
    db.maintenance_logs.insert_many(maintenance_docs)
    print(f"  [INSERT] 2 maintenance logs for Aquarium 1 (1 reminder-linked, 1 manual)")

# ---------------------------------------------------------------------------
# 7. CHATBOT SESSION + MESSAGES
# ---------------------------------------------------------------------------
if db.chatbot_sessions.count_documents({"user_id": user_id}) == 0:
    session_id = ObjectId()
    session_doc = {
        "_id": session_id,
        "user_id": user_id,
        "started_at": days_ago(1),
        "total_messages": 4,
        "updated_at": days_ago(1),
    }
    db.chatbot_sessions.insert_one(session_doc)

    msg_time = days_ago(1)
    message_docs = [
        # Valid domain query
        {
            "_id": ObjectId(),
            "session_id": session_id,
            "role": "user",
            "content": "Why is my Neon Tetra looking pale and losing colour?",
            "sent_at": msg_time,
            "is_domain_valid": True,
        },
        # Valid AI response
        {
            "_id": ObjectId(),
            "session_id": session_id,
            "role": "assistant",
            "content": (
                "Colour loss in Neon Tetras is commonly caused by stress, poor water quality "
                "(especially low pH or high ammonia), disease such as Neon Tetra Disease, or "
                "inadequate lighting. Check your pH (target 6.0â€“7.0 for Neons) and ammonia levels "
                "first. Ensure a school of at least 6 fish to reduce stress."
            ),
            "sent_at": msg_time + timedelta(seconds=2),
            "is_domain_valid": True,
        },
        # Off-topic query (domain filter rejects it)
        {
            "_id": ObjectId(),
            "session_id": session_id,
            "role": "user",
            "content": "Can you help me write a Python script for web scraping?",
            "sent_at": msg_time + timedelta(seconds=30),
            "is_domain_valid": False,
        },
        # Domain filter rejection message
        {
            "_id": ObjectId(),
            "session_id": session_id,
            "role": "assistant",
            "content": (
                "I'm AquaIntel's domain-specific assistant and can only answer questions about "
                "aquarium management, fish care, water quality, and tank maintenance. "
                "Please ask an aquarium-related question."
            ),
            "sent_at": msg_time + timedelta(seconds=31),
            "is_domain_valid": False,
        },
    ]
    db.chatbot_messages.insert_many(message_docs)
    print(f"  [INSERT] 1 chatbot session with 4 messages (2 valid, 2 filtered)")

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
print("\n" + "=" * 60)
print("  Collection document counts:")
for col in ["users", "aquariums", "fish", "water_quality_logs",
            "reminders", "maintenance_logs", "chatbot_sessions", "chatbot_messages"]:
    count = db[col].count_documents({})
    print(f"    {col:<25} {count:>4} document(s)")
print("  Sample data seeding COMPLETE âœ“")
print("=" * 60 + "\n")

