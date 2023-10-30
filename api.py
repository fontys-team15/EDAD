#!/usr/bin/env python
import os
import time
import json
from flask import Flask, abort, request, jsonify, g, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_httpauth import HTTPBasicAuth
import jwt
from werkzeug.security import generate_password_hash, check_password_hash

# initialization
app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///db.sqlite'
app.config['SQLALCHEMY_COMMIT_ON_TEARDOWN'] = True

# extensions
db = SQLAlchemy(app)
auth = HTTPBasicAuth()

# vars
template_keys = ["name", "instance_type", "associate_pub_ip"]

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(32), index=True)
    password_hash = db.Column(db.String(128))

    def hash_password(self, password):
        self.password_hash = generate_password_hash(password)

    def verify_password(self, password):
        return check_password_hash(self.password_hash, password)

    def generate_auth_token(self, expires_in=600):
        return jwt.encode(
            {'id': self.id, 'exp': time.time() + expires_in},
            app.config['SECRET_KEY'], algorithm='HS256')

    @staticmethod
    def verify_auth_token(token):
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'],
                              algorithms=['HS256'])
        except:
            return
        return User.query.get(data['id'])


@app.before_request
def print_ascii_art():
    print(pyfiglet.figlet_format("u mirin bru?"))
  
@auth.verify_password
def verify_password(username_or_token, password):
    user = User.verify_auth_token(username_or_token)
    if not user:
        user = User.query.filter_by(username=username_or_token).first()
        if not user or not user.verify_password(password):
            return False
    g.user = user
    return True


@app.route('/api/users', methods=['POST'])
def new_user():
    username = request.json.get('username')
    password = request.json.get('password')
    if username is None or password is None:
        return (jsonify({"message": "Missing arguments!"}))
    if User.query.filter_by(username=username).first() is not None:
        return (jsonify({'message': "User already exists!"}))    
    user = User(username=username)
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    token = user.generate_auth_token(600)
    return (jsonify({'message': f"Welcome {user.username}!Please remember ", 'token': token, 'duration': 600  }), 201,
            {'Location': url_for('get_user', id=user.id, _external=True)})

@app.route('/api/users/<int:id>')
def get_user(id):
    user = User.query.get(id)
    if not user:
        return jsonify({"message": "User id doesnt exist!"})
    return jsonify({'username': user.username})


@app.route('/api/token')
@auth.login_required
def get_auth_token():
    token = g.user.generate_auth_token(600)
    return jsonify({'token': token, 'duration': 600})


@app.route('/api/resource', methods=["POST"])
@auth.login_required
def get_resource():
    data = request.get_json()
    for key in data.keys():
        if key not in template_keys:
            return jsonify({"message": f"Invalid key: {key}"})
    print(json.dumps(data, indent=4, sort_keys=True))

    return jsonify({'data': f'Hello, {g.user.username}! The request was successful!'})


if __name__ == '__main__':
    if not os.path.exists('db.sqlite'):
        db.create_all()
    app.run(debug=True)
