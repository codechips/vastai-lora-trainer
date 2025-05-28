from flask import Flask, request, redirect, make_response

app = Flask(__name__)

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form['username'] == 'admin' and request.form['password'] == 'supersecret':
            resp = make_response(redirect('/srun'))
            resp.set_cookie('auth', 'valid_token', max_age=3600)
            return resp
        return "Invalid credentials", 401
    
    return '''
    <html>
    <head>
        <title>Login</title>
        <style>
            body {
                display: flex;
                justify-content: center;
                align-items: center;
                height: 100vh;
                background-color: #f0f2f5;
                font-family: Arial, sans-serif;
            }
            .login-form {
                background: #fff;
                padding: 2em;
                border-radius: 8px;
                box-shadow: 0 0 10px rgba(0,0,0,0.1);
                text-align: center;
            }
            input {
                width: 100%;
                padding: 0.5em;
                margin: 0.5em 0;
                border: 1px solid #ccc;
                border-radius: 4px;
            }
            button {
                width: 100%;
                padding: 0.5em;
                background-color: #4CAF50;
                color: white;
                border: none;
                border-radius: 4px;
                cursor: pointer;
            }
            button:hover {
                background-color: #45a049;
            }
        </style>
    </head>color
    <body>
        <form class="login-form" method="POST">
            <h2>🔐 Please Login</h2>
            <input name="username" placeholder="Username" required /><br>
            <input name="password" placeholder="Password" type="password" required /><br>
            <button type="submit">Login</button>
        </form>
    </body>
    </html>
    '''

@app.route('/logout')
def logout():
    resp = make_response(redirect('/login'))
    resp.delete_cookie('auth')
    return resp

app.run(host='0.0.0.0', port=5000)
