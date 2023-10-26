from flask import (Flask, render_template, redirect, request, session, g)
import os
import random
import bcrypt

app = Flask(__name__)

app.secret_key = os.urandom(24)


class User:
    def __init__(self, username, password, id):
        self.username = username
        self.password = password
        self.id = id

    def __repr__(self):
        return f'<{self.username}:{self.password}>'


users_list = []

id = 1

users_list.append( # add test user
    User(
        username="gg",
        password=b'$2b$12$0lFcDSbmXJQGSHj6rrdaGOL9v04wRxqMsvFkoMZNGc97MVY7z5DiK', # pass = 123
        id=id)
)



@app.before_request
def before_request():
    g.user = None
    if 'user_id' in session:
        user = [x for x in users_list if x.id == session['user_id']][0]
        g.user = user


@app.route('/')
def main_page():
    return render_template("index.html")


@app.route('/login', methods=['GET', 'POST'])
def login():
    session.pop('user_id', None)
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        for user in users_list:
            if user.username == username:
                user_password = password.encode('utf-8')
                hash = user.password
                result = bcrypt.checkpw(user_password, hash)
                if result:
                    session['user_id'] = user.id
                    return redirect('/dashboard')
        return redirect('/login')
    return render_template('login.html')


@app.route('/dashboard')
def dashboard():
    if not g.user:
        return redirect('/login')
    return render_template('dashboard.html', username=g.user.username)


@app.route('/logout')
def logout():
    session.clear()
    return redirect("/")

if __name__ == "__main__":
    app.run(port=5000, debug=True)
