from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
@app.route("/<username>")
def index(username = None):
    return render_template("index.html", username = username)