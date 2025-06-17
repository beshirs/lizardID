from flask import Flask
from flask_pymongo import PyMongo
from config import MONGO_URI

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI
mongo = PyMongo(app)

@app.route('/')
def home():
        return "Backend running"

@app.route('/testingMONGOconnection')
def testingMONGODB():
    if mongo.db is None:
        return "Mongo not connected", 500
    
    result = mongo.db.test.insert_one({"ping": "success"})
    return f"Inserted with ID: {result.inserted_id}"

if __name__ == '__main__':
    app.run(debug=True)