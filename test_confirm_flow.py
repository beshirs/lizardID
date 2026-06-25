import requests

BASE = "http://127.0.0.1:5050"

# Step 1: predict on an unknown photo
with open("test_photos/unknown1.jpg", "rb") as f:
    resp = requests.post(f"{BASE}/api/predict", files={"file": f})
result = resp.json()
print("Step 1 - predict result:", {k: v for k, v in result.items() if k != "embedding"})

if result["Lizard already seen"]:
    print("Already known, nothing to confirm.")
else:
    # Step 2: confirm it as a new lizard
    embedding = result["embedding"]
    confirm_resp = requests.post(f"{BASE}/api/confirm_new_lizard", json={"embedding": embedding})
    print("Step 2 - confirm result:", confirm_resp.json())