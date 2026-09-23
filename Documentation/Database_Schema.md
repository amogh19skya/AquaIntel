# AquaIntel — MongoDB Database Schema Documentation

**Project:** AquaIntel — A Domain-Specific AI System for Smart Aquarium Management  
**Database:** `aquaintel` (MongoDB Atlas — `AquaIntelCluster`)  
**Technology Stack:** Python 3.13 · FastAPI · PyMongo · MongoDB 7.x  
**Document Version:** 1.0  
**Date:** September 2026  
**Author:** Amogh Shakya (Student ID: 2337878)

---

## 1. Database Purpose

The `aquaintel` MongoDB database provides persistent storage for all application data managed by the AquaIntel smart aquarium mobile application. It underpins five core functional requirements identified in the contextual report (Section 5.3.1):

| Functional Requirement | Database Support |
|---|---|
| User registration and login | `users` collection |
| Aquarium and fish species management | `aquariums`, `fish` collections |
| Domain-restricted AI chatbot | `chatbot_sessions`, `chatbot_messages` collections |
| Reminder and notification system | `reminders` collection |
| Activity history and care recommendation | `maintenance_logs`, `water_quality_logs` collections |

The design is based directly on:
- **Section 5.4.2** — Entity Relationship Diagram (ERD), Figure 31
- **Section 5.4.3** — Class Diagram, Figure 32
- **Section 5.4.4/5** — Activity Diagrams, Figures 33–34

---

## 2. Database Name

```
aquaintel
```

Connection string format:
```
mongodb+srv://<user>:<password>@aquaintelcluster.sctf8ub.mongodb.net/?appName=AquaIntelCluster
```

---

## 3. Collections Overview

| # | Collection | Purpose |
|---|---|---|
| 1 | `users` | Registered user accounts |
| 2 | `aquariums` | Physical tank profiles owned by users |
| 3 | `fish` | Fish species populations within each aquarium |
| 4 | `water_quality_logs` | Append-only log of water test measurements |
| 5 | `reminders` | Scheduled maintenance task reminders |
| 6 | `maintenance_logs` | Permanent historical record of completed tasks |
| 7 | `chatbot_sessions` | AI chatbot conversation sessions |
| 8 | `chatbot_messages` | Individual messages within chatbot sessions |

---

## 4. Detailed Collection Schemas

### 4.1 `users`

Stores registered AquaIntel user accounts. Every other collection either directly or indirectly references a user.

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `fullname` | `string` | Yes | User's full name |
| `email` | `string` | Yes | Unique email address (used for login) |
| `password_hash` | `string` | Yes | bcrypt hash of the user's password (plaintext never stored) |
| `phone_number` | `string` | No | Optional contact number |
| `created_at` | `date` | Yes | UTC timestamp of account creation |

**Validation rules:**
- `email`, `fullname`, `password_hash`, `created_at` are required.
- `email` must be unique (enforced via unique index).

**Indexes:**
```json
{ "email": 1 }   // unique: true, name: "email_unique"
```

---

### 4.2 `aquariums`

Represents physical aquarium tanks owned by a user. The ERD (Figure 31) identifies `Aquarium` as the **central hub entity** — nearly all other entities link back to it.

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `user_id` | `ObjectId` | Yes | FK → `users._id` |
| `tank_name` | `string` | Yes | Descriptive name (e.g., "Living Room Reef") |
| `tank_size_litres` | `double` | Yes | Tank volume in litres (> 0) |
| `tank_type` | `string` | Yes | Enum: `Freshwater`, `Saltwater`, `Brackish`, `Planted`, `Reef`, `Coldwater` |
| `setup_date` | `date` | Yes | Date tank was established |
| `notes` | `string` | No | Optional equipment or substrate notes |
| `created_at` | `date` | Yes | Timestamp |

**Indexes:**
```json
{ "user_id": 1 }   // name: "aquariums_user_id"
```

---

### 4.3 `fish`

Tracks species populations within a tank, not individual fish. The `health_status` field directly drives **dashboard colour coding** as documented in the ERD notes (Page 58).

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `aquarium_id` | `ObjectId` | Yes | FK → `aquariums._id` |
| `species_name` | `string` | Yes | Scientific/formal species name |
| `common_name` | `string` | Yes | Common name |
| `quantity` | `int` | Yes | Count of fish in tank (minimum: 1) |
| `health_status` | `string` | Yes | Enum: `Healthy`, `Sick`, `Dead` — drives dashboard colour |
| `date_added` | `date` | Yes | Date species was added |
| `notes` | `string` | No | Optional observations |

**Indexes:**
```json
{ "aquarium_id": 1 }   // name: "fish_aquarium_id"
```

---

### 4.4 `water_quality_logs`

An **append-only** log. Each test reading inserts a new document. The latest row determines the dashboard health indicator; all rows produce the 30-day trend chart referenced in Pages 58–59.

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `aquarium_id` | `ObjectId` | Yes | FK → `aquariums._id` |
| `ph_level` | `double` | Yes | pH reading (0.0 – 14.0) |
| `temperature_c` | `double` | Yes | Temperature in Celsius (0.0 – 60.0) |
| `ammonia_ppm` | `double` | No | Ammonia in parts per million (>= 0.0) |
| `nitrate_ppm` | `double` | No | Nitrate in parts per million (>= 0.0) |
| `recorded_at` | `date` | Yes | Timestamp of the water test |

**Indexes:**
```json
{ "aquarium_id": 1, "recorded_at": -1 }   // name: "wq_aquarium_date"
// Supports: latest reading lookup + 30-day pH trend chart queries
```

---

### 4.5 `reminders`

Stores scheduled maintenance reminders. The ERD (Figure 31, Page 58) specifies two lifecycle booleans: `is_sent` (fired when notification delivered) and `is_completed` (fired when user interacts). Completing a reminder automatically triggers a `maintenance_logs` entry.

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `user_id` | `ObjectId` | Yes | FK → `users._id` |
| `aquarium_id` | `ObjectId` | Yes | FK → `aquariums._id` |
| `reminder_type` | `string` | Yes | Enum: `Feeding`, `Water Change`, `Filter Cleaning`, `Water Testing`, `Tank Cleaning`, `Medication`, `Other` |
| `scheduled_at` | `date` | Yes | Scheduled execution time |
| `is_completed` | `bool` | Yes | True after user completes the task (default: `false`) |
| `is_sent` | `bool` | Yes | True after push notification sent (default: `false`) |
| `is_recurring` | `bool` | Yes | True for repeating reminders (default: `false`) |
| `interval_days` | `int` | No | Repeat interval in days (required when `is_recurring=true`, minimum: 1) |
| `created_at` | `date` | Yes | Timestamp |

**Indexes:**
```json
{ "user_id": 1, "is_completed": 1, "scheduled_at": 1 }   // name: "reminders_pending"
// Supports: fetch pending reminders for a user, ordered by due date
{ "aquarium_id": 1 }   // name: "reminders_aquarium_id"
```

---

### 4.6 `maintenance_logs`

Provides the permanent historical record of all care activities. It is generated automatically when a reminder is completed, or can be entered manually. As documented (Page 59): *"reminder_id FK is nullable — when a user enters a task manually, reminder_id is set to null, but the log record remains"*.

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `aquarium_id` | `ObjectId` | Yes | FK → `aquariums._id` |
| `reminder_id` | `ObjectId` \| `null` | No | FK → `reminders._id` (null for manual entries) |
| `task_type` | `string` | Yes | Enum: `Feeding`, `Water Change`, `Filter Cleaning`, `Water Testing`, `Tank Cleaning`, `Medication`, `Other` |
| `completed_at` | `date` | Yes | Completion timestamp |
| `notes` | `string` | No | Optional task-specific notes |

**Indexes:**
```json
{ "aquarium_id": 1, "completed_at": -1 }   // name: "ml_aquarium_date"
// Supports: fetch recent maintenance history for a tank
{ "reminder_id": 1 }   // sparse: true, name: "ml_reminder_id"
// Supports: link completed reminder to its log entry
```

---

### 4.7 `chatbot_sessions`

Organises AI messages within a single conversation. The `total_messages` counter implements **API rate limiting** to control AI API costs, as described on Page 59.

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `user_id` | `ObjectId` | Yes | FK → `users._id` |
| `started_at` | `date` | Yes | Session start timestamp |
| `total_messages` | `int` | Yes | Count of messages for rate limiting (minimum: 0, default: 0) |
| `updated_at` | `date` | Yes | Timestamp of the last message |

**Indexes:**
```json
{ "user_id": 1, "updated_at": -1 }   // name: "cs_user_updated"
// Supports: fetch user's recent chat sessions
```

---

### 4.8 `chatbot_messages`

Individual messages in a chatbot session. The `is_domain_valid` boolean flag enforces the domain restriction **at the data level** — a key architectural decision described in the ERD notes (Page 58–59): *"The is_domain_valid flag sets all messages true (aquarium queries) and a real AI response; off-topic queries get false and a rejection message."*

| Field | BSON Type | Required | Description |
|---|---|---|---|
| `_id` | `ObjectId` | Yes | Auto-generated primary key |
| `session_id` | `ObjectId` | Yes | FK → `chatbot_sessions._id` |
| `role` | `string` | Yes | Enum: `user`, `assistant`, `system` |
| `content` | `string` | Yes | Text of the message |
| `sent_at` | `date` | Yes | Message timestamp |
| `is_domain_valid` | `bool` | Yes | `true` = aquarium-related; `false` = rejected by domain filter |

**Indexes:**
```json
{ "session_id": 1, "sent_at": 1 }   // name: "cm_session_time"
// Supports: load chronological conversation stream
```

---

## 5. Entity Relationship Diagram

Based on Figure 31 from the AquaIntel Contextual Report (Section 5.4.2):

```
USERS
  |
  |-- (1:N) --> AQUARIUMS
  |                |
  |                |-- (1:N) --> FISH
  |                |-- (1:N) --> WATER_QUALITY_LOGS
  |                |-- (1:N) --> REMINDERS -----> (1:0|1) --> MAINTENANCE_LOGS
  |
  |-- (1:N) --> REMINDERS (user_id also on reminders for notification targeting)
  |-- (1:N) --> CHATBOT_SESSIONS
                     |
                     |-- (1:N) --> CHATBOT_MESSAGES
```

### ObjectId Reference Summary

| Collection | Field | References |
|---|---|---|
| `aquariums` | `user_id` | `users._id` |
| `fish` | `aquarium_id` | `aquariums._id` |
| `water_quality_logs` | `aquarium_id` | `aquariums._id` |
| `reminders` | `user_id` | `users._id` |
| `reminders` | `aquarium_id` | `aquariums._id` |
| `maintenance_logs` | `aquarium_id` | `aquariums._id` |
| `maintenance_logs` | `reminder_id` | `reminders._id` (nullable) |
| `chatbot_sessions` | `user_id` | `users._id` |
| `chatbot_messages` | `session_id` | `chatbot_sessions._id` |

---

## 6. Validation Rules Summary

All validation is implemented using MongoDB `$jsonSchema` validators configured via `init_db.py`.

| Collection | Key Constraints |
|---|---|
| `users` | `email` unique; `password_hash`, `fullname`, `created_at` required |
| `aquariums` | `tank_size_litres > 0`; `tank_type` enum enforced |
| `fish` | `quantity >= 1`; `health_status` enum `["Healthy", "Sick", "Dead"]` |
| `water_quality_logs` | `ph_level` range 0–14; `temperature_c` range 0–60 |
| `reminders` | `reminder_type` enum; `is_completed`, `is_sent`, `is_recurring` are booleans |
| `maintenance_logs` | `task_type` enum; `reminder_id` accepts `ObjectId` or `null` |
| `chatbot_sessions` | `total_messages >= 0` |
| `chatbot_messages` | `role` enum `["user", "assistant", "system"]`; `is_domain_valid` is bool |

---

## 7. Index Summary

| Collection | Index | Type | Purpose |
|---|---|---|---|
| `users` | `email_unique` | Unique | Prevent duplicate accounts; fast login lookup |
| `aquariums` | `aquariums_user_id` | Single | Fetch all tanks for a user (dashboard load) |
| `fish` | `fish_aquarium_id` | Single | Fetch all fish in a tank |
| `water_quality_logs` | `wq_aquarium_date` | Compound (asc/desc) | Latest reading + 30-day trend chart |
| `reminders` | `reminders_pending` | Compound | Fetch pending reminders ordered by due date |
| `reminders` | `reminders_aquarium_id` | Single | Reminders per aquarium |
| `maintenance_logs` | `ml_aquarium_date` | Compound (asc/desc) | Recent care history per tank |
| `maintenance_logs` | `ml_reminder_id` | Sparse | Link maintenance entry to its reminder |
| `chatbot_sessions` | `cs_user_updated` | Compound (asc/desc) | Recent sessions per user |
| `chatbot_messages` | `cm_session_time` | Compound | Chronological conversation stream |

---

## 8. Sample Documents

### `users`
```json
{
  "_id": ObjectId("6ab35ea8a3b3dcb3f1973fd5"),
  "fullname": "Amogh Shakya",
  "email": "amogh@aquaintel.dev",
  "password_hash": "$2b$12$<bcrypt_hash>",
  "phone_number": "+977-9800000001",
  "created_at": ISODate("2026-07-24T00:00:00Z")
}
```

### `aquariums`
```json
{
  "_id": ObjectId("6ab35ea9a3b3dcb3f1973fd6"),
  "user_id": ObjectId("6ab35ea8a3b3dcb3f1973fd5"),
  "tank_name": "Living Room Planted Tank",
  "tank_size_litres": 120.0,
  "tank_type": "Planted",
  "setup_date": ISODate("2026-06-24T00:00:00Z"),
  "notes": "Fluval 307 canister filter; CO2 injection; Seachem Flourite substrate",
  "created_at": ISODate("2026-06-24T00:00:00Z")
}
```

### `fish`
```json
{
  "_id": ObjectId("..."),
  "aquarium_id": ObjectId("6ab35ea9a3b3dcb3f1973fd6"),
  "species_name": "Paracheirodon innesi",
  "common_name": "Neon Tetra",
  "quantity": 12,
  "health_status": "Healthy",
  "date_added": ISODate("2026-06-29T00:00:00Z"),
  "notes": "Schooling fish; prefer dimly lit areas"
}
```

### `water_quality_logs`
```json
{
  "_id": ObjectId("..."),
  "aquarium_id": ObjectId("6ab35ea9a3b3dcb3f1973fd6"),
  "ph_level": 7.1,
  "temperature_c": 26.5,
  "ammonia_ppm": 0.0,
  "nitrate_ppm": 6.0,
  "recorded_at": ISODate("2026-09-22T00:00:00Z")
}
```

### `reminders`
```json
{
  "_id": ObjectId("..."),
  "user_id": ObjectId("6ab35ea8a3b3dcb3f1973fd5"),
  "aquarium_id": ObjectId("6ab35ea9a3b3dcb3f1973fd6"),
  "reminder_type": "Water Change",
  "scheduled_at": ISODate("2026-09-25T00:00:00Z"),
  "is_completed": false,
  "is_sent": false,
  "is_recurring": true,
  "interval_days": 14,
  "created_at": ISODate("2026-08-24T00:00:00Z")
}
```

### `maintenance_logs` (reminder-linked)
```json
{
  "_id": ObjectId("..."),
  "aquarium_id": ObjectId("6ab35ea9a3b3dcb3f1973fd6"),
  "reminder_id": ObjectId("..."),
  "task_type": "Feeding",
  "completed_at": ISODate("2026-09-20T00:00:00Z"),
  "notes": "Fed 2 pinches of tropical flakes"
}
```

### `maintenance_logs` (manual entry)
```json
{
  "_id": ObjectId("..."),
  "aquarium_id": ObjectId("6ab35ea9a3b3dcb3f1973fd6"),
  "reminder_id": null,
  "task_type": "Tank Cleaning",
  "completed_at": ISODate("2026-09-16T00:00:00Z"),
  "notes": "Scrubbed algae from front glass; vacuumed substrate"
}
```

### `chatbot_sessions`
```json
{
  "_id": ObjectId("..."),
  "user_id": ObjectId("6ab35ea8a3b3dcb3f1973fd5"),
  "started_at": ISODate("2026-09-22T00:00:00Z"),
  "total_messages": 4,
  "updated_at": ISODate("2026-09-22T00:01:00Z")
}
```

### `chatbot_messages` (valid query)
```json
{
  "_id": ObjectId("..."),
  "session_id": ObjectId("..."),
  "role": "user",
  "content": "Why is my Neon Tetra looking pale and losing colour?",
  "sent_at": ISODate("2026-09-22T00:00:00Z"),
  "is_domain_valid": true
}
```

### `chatbot_messages` (domain-filtered)
```json
{
  "_id": ObjectId("..."),
  "session_id": ObjectId("..."),
  "role": "user",
  "content": "Can you help me write a Python script for web scraping?",
  "sent_at": ISODate("2026-09-22T00:00:30Z"),
  "is_domain_valid": false
}
```

---

## 9. How the Database Supports AquaIntel

| Application Feature | Collections Used |
|---|---|
| **Login / Registration** | `users` |
| **Dashboard health indicator** | `water_quality_logs` (latest row), `fish` (health_status) |
| **30-day pH trend chart** | `water_quality_logs` (all rows, date-ordered) |
| **Fish compatibility checker** | `fish` (species in same aquarium) |
| **Reminder scheduling** | `reminders` (is_sent, scheduled_at) |
| **Push notification tracking** | `reminders` (is_sent boolean) |
| **Maintenance history log** | `maintenance_logs` |
| **AI chatbot session** | `chatbot_sessions`, `chatbot_messages` |
| **Domain filter enforcement** | `chatbot_messages.is_domain_valid` |
| **API cost/rate limiting** | `chatbot_sessions.total_messages` |
| **User profile management** | `users` |

---

## 10. Implementation Files

| File | Purpose |
|---|---|
| `backend/database.py` | MongoDB client with Atlas + local fallback |
| `backend/db/init_db.py` | Creates collections, validators, and indexes |
| `backend/db/seed_data.py` | Inserts realistic test data |
| `backend/db/verify_db.py` | Automated schema and referential integrity checks |

---

*This documentation was prepared as part of the AquaIntel final-year project — Student ID: 2337878.*
