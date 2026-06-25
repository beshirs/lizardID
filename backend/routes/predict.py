import os
import uuid
import numpy as np
import tensorflow as tf
from flask import Blueprint, request, jsonify
from PIL import Image
from extensions import mongo 

predict_bp = Blueprint("predict", __name__, url_prefix="/api")

coll = mongo.db.lizard_emeddings

# preload
saved = {
    doc["lizard_id"]: np.array(doc["embedding"], dtype=np.float32)
    for doc in coll.find({})
}
print(f"loaded {len(saved)} embeddings from mongodb")

# building the MobileNetV2-based embedding model
base_model = tf.keras.applications.MobileNetV2(
    input_shape=(224,224,3),
    include_top=False,
    weights="imagenet"
)
model = tf.keras.Sequential([
    base_model,
    tf.keras.layers.GlobalAveragePooling2D()
])

def compute_embedding(path):
    img = Image.open(path).resize((224,224))
    arr = tf.keras.applications.mobilenet_v2.preprocess_input(
        np.array(img, dtype=np.float32)
    )
    emb = model(np.expand_dims(arr, 0))[0].numpy()
    return emb / np.linalg.norm(emb)

@predict_bp.route("/predict", methods=["POST"])
def predict_route():
    file = request.files.get("file")
    if not file:
        return jsonify({"error": "No file provided"}), 400

    ext = os.path.splitext(file.filename)[1]
    tmp = f"/tmp/{uuid.uuid4().hex}{ext}"
    file.save(tmp)

    new_emb = compute_embedding(tmp)
    best_id, best_score = None, -1.0
    for lid, ref_emb in saved.items():
        score = float(np.dot(new_emb, ref_emb))
        if score > best_score:
            best_id, best_score = lid, score

    try:
        os.remove(tmp)
    except:
        pass

    if best_score >= 0.8:
        return jsonify({"Lizard already seen": True,  "id": best_id,   "score": best_score})
    else:
        # No match found — return the embedding so the client can confirm before saving
        return jsonify({
            "Lizard already seen": False,
            "score": best_score,
            "embedding": new_emb.tolist(),
        })


@predict_bp.route("/confirm_new_lizard", methods=["POST"])
def confirm_new_lizard():
    # Step 2 of the confirm flow: client sends back the embedding to register a new lizard
    data = request.get_json()
    if not data or "embedding" not in data:
        return jsonify({"error": "Missing 'embedding' field in request body"}), 400

    embedding_list = data["embedding"]
    new_id = f"lizard_{uuid.uuid4().hex[:8]}"
    emb_array = np.array(embedding_list, dtype=np.float32)

    # Persist to MongoDB (as a plain list) and update in-memory cache for immediate matching
    coll.insert_one({"lizard_id": new_id, "embedding": embedding_list})
    saved[new_id] = emb_array

    return jsonify({"status": "saved", "lizard_id": new_id})


