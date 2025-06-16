from datetime import datetime

def create_lizard_doc(lizard_id, notes=""):
    return {
        "lizard_id": lizard_id,
        "notes": notes,
        "created_at": datetime.utcnow()
    }