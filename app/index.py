from flask import Flask, render_template
import os
import pymysql

app = Flask(__name__)

def get_db_connection():
    conn = pymysql.connect(
        host=os.getenv('RDS_ENDPOINT', 'localhost'),
        user=os.getenv('RDS_USER', 'admin'), 
        password=os.getenv('RDS_PASSWORD', 'yo'), 
        db='SOONGSIL_STUDENT_CAFETERIA_SCM', 
        charset='utf8')
    return conn

@app.route('/', methods=['GET'])
def home():
    try:
        conn = get_db_connection()
        cursor = conn.cursor(pymysql.cursors.DictCursor)
        
        cursor.execute("SELECT * FROM MENU ORDER BY Date")
        data = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        return render_template('index.html', data=data), 200
        
    except Exception as e:
        return str(e), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)

