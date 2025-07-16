from flask import Flask
from config import MONGO_URI
from extensions import mongo
from routes.upload import upload_bp
from flask_cors import CORS
from flask import jsonify
from datetime import datetime

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI
CORS(app, resources={r"/api*":{"origins":"*"}}) #prevents CORS errors

mongo.init_app(app)

from routes.predict import predict_bp

app.register_blueprint(upload_bp)
app.register_blueprint(predict_bp)

@app.route('/')
def home():
    return "Backend running"

@app.route('/testingMONGOconnection')
def testingMONGODB():
    result = mongo.db.test.insert_one({"ping": "success"})
    return f"Inserted with ID: {result.inserted_id}"

@app.route('/api/count')
def count():
    return {"count": mongo.db.lizard_emeddings.count_documents({})}

@app.route("/api/health", methods=["GET"])
def health():
    return jsonify({"status":"ok","time": datetime.utcnow().isoformat()}),200

if __name__ == '__main__':
    print(app.url_map)
    app.run(debug=True, port=5050)
