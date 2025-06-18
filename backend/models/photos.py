from datetime import datetime

def create_photo_doc(filename, lizard_id, gps, device_id):
    return {
        "filename": filename,
        "lizard_id": lizard_id,
        "gps_location": gps,
        "device_id": device_id,
        "timestamp": datetime.utcnow()
    }
