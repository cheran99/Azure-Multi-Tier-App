from flask import Flask, render_template, jsonify, request, session, redirect, url_for
import os
import mysql.connector

app = Flask(__name__)

app.secret_key = 'thisisasecretkey'

host = os.getenv('AZURE_MYSQL_HOST')
user = os.getenv('AZURE_MYSQL_USER')
password = os.getenv('AZURE_MYSQL_PASSWORD')
database = os.getenv('AZURE_MYSQL_NAME')
ssl_cert_path = os.path.join(os.path.dirname(__file__), "certs", "DigiCertGlobalRootCA.crt.pem")

admin_user = user
admin_password = password

def get_db_connection():
    try:
        cnx = mysql.connector.connect(
            user=user, 
            password=password, 
            host=host, 
            port=3306, 
            database=database, 
            ssl_ca=ssl_cert_path,
            ssl_disabled=False
        )
        print("Database connection successful.")
        return cnx
    except mysql.connector.Error as err:
        print(f"Database Connection Error: {err}")
        return None   
        

@app.route("/", methods = ['GET', 'POST'])
def index():
    conn = get_db_connection()
    if not conn:
        return "Database connection failed", 500
    
    cursor = conn.cursor()
    

    if request.method == 'POST':
        name = request.form['name']
        gender = request.form['gender']
        age = request.form['age']
        car_brand = request.form['car_brand']
        
        query = "INSERT INTO app_user (name, gender, age, car_brand) VALUES (%s, %s, %s, %s);"
        values = (name, gender, age, car_brand)
        cursor.execute(query, values)
        conn.commit()

    cursor.execute("SELECT * FROM app_user") 
    results = cursor.fetchall()
    
    cursor.close()
    conn.close()    
    return render_template("index.html", results=results)

@app.route('/login', methods=['GET', 'POST'])
def login():
    msg = ''
    if request.method == 'POST' and 'admin' in request.form and 'password' in request.form:
        print("Login form submitted.")
        print("Form data:", request.form)

        admin = request.form['admin']
        password = request.form['password']

        print(f"Admin input: {admin}")
        print(f"Password input: {password}")

        if admin == admin_user and password == admin_password:
            session['admin'] = admin
            print("Login successful!")
            return redirect(url_for('dashboard'))
        else:
            msg = "Invalid credentials"
            print("Login failed.")
    return render_template("login.html", msg = msg)

@app.route('/dashboard', methods=['GET', 'POST'])
def dashboard():
    if session.get('admin') != admin_user:
        return redirect(url_for('login'))

    if session.get('admin') == admin_user:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM app_user") 
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return render_template("dashboard.html", results=data)
    else:
        return "Access denied: Admins only", 403


@app.route('/logout')
def logout():
    session.pop('admin', None)
    return redirect(url_for('index'))

@app.route("/health")
def health_check():
    return "Backend is running"

@app.route("/data")
def get_data():
    if session.get('admin') != admin_user:
        return redirect(url_for('login'))
    
    if session.get('admin') == admin_user:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM app_user") 
        data = cursor.fetchall()
        cursor.close()
        conn.close()
        return jsonify({"data": data})
    else:
        return jsonify({"error": "Failed to connect to database"}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    app.run(host="0.0.0.0", port=port)
