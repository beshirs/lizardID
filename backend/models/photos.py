from datetime import datetime

def create_phot_lizard(filename, lizard_id, gps, device_id)
    return{
        "filename": filename,
        "lizard_id": lizard_id,
        "gps": gps,
        "device_id": device_id
        "timestamp": datetime.utcnow()
    }