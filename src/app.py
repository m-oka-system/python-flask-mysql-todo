import os
from dotenv import load_dotenv

from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime, timezone, timedelta

# 環境変数の読み込み
load_dotenv()

app = Flask(__name__)

# 本番環境かどうかを判定
IS_PRODUCTION = os.getenv('IS_PRODUCTION', 'False').lower() == 'true'

if IS_PRODUCTION:
    # 本番環境（Azure MySQL）の設定
    db_user = os.getenv('DB_USER')
    db_password = os.getenv('DB_PASSWORD')
    db_host = os.getenv('DB_HOST')
    db_port = os.getenv('DB_PORT', '3306')
    db_name = os.getenv('DB_NAME')
    ssl_ca = os.getenv('SSL_CA', "DigiCertGlobalRootCA.crt.pem")

    # SSL接続の有効/無効を環境変数で制御
    use_ssl = os.getenv('MYSQL_USE_SSL', 'True').lower() == 'true'

    # SSL設定に基づいてデータベースURIを構築
    if use_ssl:
        SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}?ssl_ca={ssl_ca}"
    else:
        SQLALCHEMY_DATABASE_URI = f"mysql+pymysql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"

else:
    # 開発環境（SQLite）の設定
    SQLALCHEMY_DATABASE_URI = os.getenv('SQLITE_URL', 'sqlite:///todo.db')

# データベース設定の適用
app.config['SQLALCHEMY_DATABASE_URI'] = SQLALCHEMY_DATABASE_URI
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class Todo(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    created_at = db.Column(db.DateTime, nullable=False, default=datetime.utcnow)
    completed = db.Column(db.Boolean, default=False)

    @property
    def created_at_jst(self):
        # created_atをJST（日本時間）で返す
        return self.created_at.replace(tzinfo=timezone.utc).astimezone(
            timezone(timedelta(hours=9))
        )

with app.app_context():
    db.create_all()

@app.route('/')
def index():
    todos = Todo.query.order_by(Todo.created_at.desc()).all()
    return render_template('index.html', todos=todos)

@app.route('/add', methods=['POST'])
def add():
    title = request.form.get('title')
    if title:
        todo = Todo(title=title)
        db.session.add(todo)
        db.session.commit()
    return redirect(url_for('index'))

@app.route('/toggle/<int:id>')
def toggle(id):
    todo = Todo.query.get(id)
    if todo:
        todo.completed = not todo.completed
        db.session.commit()
    return redirect(url_for('index'))

@app.route('/delete/<int:id>')
def delete(id):
    todo = Todo.query.get(id)
    if todo:
        db.session.delete(todo)
        db.session.commit()
    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
