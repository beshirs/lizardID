from flask import Flask
from config import MONGO_URI
from extensions import mongo
from routes.upload import upload_bp
# remove or comment out this import for now:
# from routes.predict import predict_bp

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI

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

if __name__ == '__main__':
    print(app.url_map)
    app.run(debug=True, port=5050)
