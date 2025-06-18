from flask import Blueprint, jsonify, request
from app import mongo

photos_bp = Blueprint('photos', __name__)

@photos_bp.route('/photos', methods=['GET'])
def get_photos():
    lizard_id = request.args.get('lizard_id')
    query = {"lizard_id": lizard_id} if lizard_id else {}
    photos = mongo.db.photos.find(query)

    result = []
    for photo in photos:
        photo["_id"] = str(photo["_id"])
        result.append(photo)

    return jsonify(result)
