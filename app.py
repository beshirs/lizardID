from flask import flask
from flask_pymongo import PyMongo

app = Flask(__name__)
app.config["MONGO_URI"] = MONGO_URI
mongo = PyMongo(app)

if __name__ == '__main__':
    app.run(debug=True)