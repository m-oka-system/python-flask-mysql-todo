## ローカル環境で実行

1. リポジトリのクローン

```bash
git clone https://github.com/m-oka-system/python-flask-mysql-todo.git
cd python-flask-mysql-todo/src
```

2. 仮想環境の作成と有効化

```bash
# 仮想環境の作成
python -m venv .venv

# 仮想環境の有効化
# Windows (cmd.exe)の場合
.venv\Scripts\activate.bat

# Windows (PowerShell)の場合
.venv\Scripts\Activate.ps1

# bash/zshの場合
source .venv/bin/activate
```

3. 依存パッケージのインストール

```bash
pip install -r requirements.txt
```

4. .env ファイルの作成

```bash
# bash/zshの場合
cp .env.sample .env

# Windows の場合
copy .env.sample .env
```

5. アプリケーションの起動

```bash
python app.py
```

6. ブラウザで以下の URL にアクセス

```
http://localhost:5000
```
