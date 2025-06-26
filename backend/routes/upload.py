# file for handling /upload endpoint
from flask import Blueprint, request, jsonify
from werkzeug.utils import secure_filename
from datetime import datetime
import os

from extensions import mongo
from models.photos import create_photo_doc

upload_bp = Blueprint('upload', __name__)
UPLOAD_FOLDER = 'static/images/'
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@upload_bp.route('/upload', methods=['POST'])
def upload():
    image = request.files.get('image')
    if not image:
        return jsonify({"error": "No image uploaded"}), 400

    filename = secure_filename(image.filename)
    path = os.path.join(UPLOAD_FOLDER, filename)
    image.save(path)

    metadata = create_photo_doc(
        filename=filename,
        lizard_id=request.form.get('lizard_id'),
        gps=request.form.get('gps_location'),
        device_id=request.form.get('device_id')
    )
    mongo.db.photos.insert_one(metadata)
    return jsonify({"status": "success", "filename": filename})
