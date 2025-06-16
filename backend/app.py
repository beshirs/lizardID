from flask import Flask
from flask_pymongo import PyMongo
from config import MONGO_URI

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI
mongo = PyMongo(app)

@app.route('/')
def home():
        return "Backend running"

if __name__ == '__main__':
    app.run(debug=True)