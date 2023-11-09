import time
import json
import pyfiglet
import requests
from flask import Flask,request, jsonify, g, url_for,render_template
from flask_sqlalchemy import SQLAlchemy
from flask_httpauth import HTTPBasicAuth
import jwt
from werkzeug.security import generate_password_hash, check_password_hash

# initialization
app = Flask(__name__)
app.config['SECRET_KEY'] = 'the quick brown fox jumps over the lazy dog'
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:123@127.0.0.1:3306/mydb'
app.config['SQLALCHEMY_COMMIT_ON_TEARDOWN'] = True

# extensions
db = SQLAlchemy(app)
auth = HTTPBasicAuth()

# vars
template_keys = ["name", "instance_type", "associate_pub_ip"]
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(32), index=True)
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
def verify_password(email_or_token, password):
    user = User.verify_auth_token(email_or_token)
    if not user:
        user = User.query.filter_by(email=email_or_token).first()
        if not user or not user.verify_password(password):
            return False
    g.user = user
    return True


@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/users', methods=['POST'])
def new_user():
    email = request.json.get('email')
    password = request.json.get('password')
    if email is None or password is None:
        return (jsonify({"message": "Missing arguments!"})), 401
    if User.query.filter_by(email=email).first() is not None:
        return (jsonify({'message': "User already exists!"})), 409
    user = User(email=email)
    user.hash_password(password)
    db.session.add(user)
    db.session.commit()
    token = user.generate_auth_token(600)
    return (jsonify({'message': f"Welcome {user.email}!Please remember ", 'token': token, 'duration': 600  }), 201,
            {'Location': url_for('get_user', id=user.id, _external=True)})


@app.route('/api/users/rm', methods=['DELETE'])
@auth.login_required
def remove_user():
    db.session.delete(g.user)
    db.session.commit()
    return jsonify({"message": "Successfully unregistered"}), 200

@app.route('/api/users/<int:id>')
def get_user(id):
    user = User.query.get(id)
    if not user:
        return jsonify({"message": "User id doesnt exist!"}), 401
    return jsonify({'email': f'{user.email}'})

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

    try:
        r = requests.post("https://pb0w7r2ew5.execute-api.eu-central-1.amazonaws.com/1/step", json={
            "input": "{}",
            "name": f"{g.user.email}",
            "stateMachineArn": "arn:aws:states:eu-central-1:657026912035:stateMachine:CreditCardWorkflow"
    })
    except:
        return r

    return jsonify({'data': f'Hello, {g.user.email}!The request was successful! The step func returned this response: {r}'})


if __name__ == '__main__':
    if not db.engine.has_table('users'):
        db.create_all()
    app.run()
