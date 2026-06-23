"""
Export reference lizard embeddings from MongoDB to a JSON file for the iOS app.

Run from the project root or ml/ folder:
    python ml/export_reference_embeddings.py
"""

import json
import os
from pathlib import Path

from dotenv import load_dotenv
from pymongo import MongoClient


load_dotenv()
load_dotenv(Path(__file__).resolve().parent.parent / "backend" / ".env")

MONGO_URI = os.getenv("MONGO_URI")
if not MONGO_URI:
    raise RuntimeError(
        "MONGO_URI is not set. Add it to backend/.env or export it in your shell."
    )


client = MongoClient(MONGO_URI)
db = client.get_default_database()
collection = db["lizard_emeddings"]


records = []
for doc in collection.find({}):
    records.append(
        {
            "id": doc["lizard_id"],
            "vector": doc["embedding"],
        }
    )


output_path = os.path.join(os.path.dirname(__file__), "reference_embeddings.json")
with open(output_path, "w", encoding="utf-8") as f:
    json.dump(records, f, indent=2)
    f.write("\n")

print(f"Exported {len(records)} record(s) to {output_path}")
