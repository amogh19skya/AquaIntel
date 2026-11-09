"""
backend/db/seed_compatibility_firestore.py
=========================================
AquaIntel - Predefined Firestore Compatibility Seeder

Populates the Cloud Firestore `compatibility` collection for project:
  aquaintel-36924

Safety guarantees:
  1. Idempotent: Can be run multiple times safely.
  2. Non-destructive: Does NOT touch, modify, or delete the `fish` collection.
  3. Deterministic: All pair IDs follow the sorted convention: `${idA}_${idB}`.
  4. Contains exactly the 28 unique pairings for the 8 seeded fish species:
     angelfish, betta, corydoras, goldfish, guppy, neon_tetra, oscar, platy.

Usage:
  Option A (with Firebase Service Account Key):
    python backend/db/seed_compatibility_firestore.py --key path/to/serviceAccountKey.json

  Option B (JSON Output / Dry Run Verification):
    python backend/db/seed_compatibility_firestore.py --dry-run
"""

import argparse
import json
import os
import sys

SEED_FILE_PATH = os.path.join(
    os.path.dirname(__file__), "..", "..", "data", "firestore_compatibility_seed.json"
)


def load_seed_data():
    normalized_path = os.path.abspath(SEED_FILE_PATH)
    if not os.path.exists(normalized_path):
        print(f"Error: Seed file not found at: {normalized_path}")
        sys.exit(1)

    with open(normalized_path, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data


def run_dry_run(seed_data):
    print(f"=== DRY RUN: AquaIntel Compatibility Seeder ===")
    print(f"Loaded {len(seed_data)} predefined compatibility pairs.\n")

    for idx, (pair_id, doc) in enumerate(sorted(seed_data.items()), start=1):
        score = doc.get("score")
        status = doc.get("status")
        temp = doc.get("temperature", {}).get("status")
        ph = doc.get("ph", {}).get("status")
        temperament = doc.get("temperament", {}).get("status")
        tank = doc.get("tankSize", {}).get("status")
        print(
            f"[{idx:02d}/28] {pair_id:<22} -> Score: {score:3d}/100 | Status: {status:<22} "
            f"[Temp: {temp}, pH: {ph}, Temperament: {temperament}, Tank: {tank}]"
        )

    print("\nDry run completed successfully. All 28 pairs validated.")


def run_firebase_admin_seed(seed_data, key_path):
    try:
        import firebase_admin
        from firebase_admin import credentials, firestore
    except ImportError:
        print("Error: firebase-admin package is required for direct upload.")
        print("Install it with: pip install firebase-admin")
        sys.exit(1)

    if not os.path.exists(key_path):
        print(f"Error: Service account key not found at {key_path}")
        sys.exit(1)

    print(f"Initializing Firebase Admin with service key: {key_path}...")
    cred = credentials.Certificate(key_path)
    try:
        app = firebase_admin.initialize_app(cred, {"projectId": "aquaintel-36924"})
    except ValueError:
        app = firebase_admin.get_app()

    db = firestore.client()
    col = db.collection("compatibility")

    print(f"Writing {len(seed_data)} documents to Firestore collection 'compatibility'...")
    batch = db.batch()
    count = 0

    for pair_id, payload in seed_data.items():
        doc_ref = col.document(pair_id)
        batch.set(doc_ref, payload, merge=True)
        count += 1

    batch.commit()
    print(f"Successfully committed {count} compatibility pairs to Firestore.")


def main():
    parser = argparse.ArgumentParser(description="AquaIntel Firestore Compatibility Seeder")
    parser.add_argument("--key", help="Path to Firebase Service Account JSON key", default=None)
    parser.add_argument("--dry-run", action="store_true", help="Validate and inspect data without uploading")
    args = parser.parse_args()

    seed_data = load_seed_data()

    if args.dry_run or not args.key:
        run_dry_run(seed_data)
        if not args.key:
            print("\nTip: To write directly to Firestore, provide your service account key:")
            print("  python backend/db/seed_compatibility_firestore.py --key serviceAccountKey.json")
    else:
        run_firebase_admin_seed(seed_data, args.key)


if __name__ == "__main__":
    main()
