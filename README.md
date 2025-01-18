# Todo アプリ

シンプルな Todo アプリケーションです。レスポンシブ対応しています。
Flask と Tailwind CSS を使用して構築されたモダンなデザインのタスク管理ツールです。
<img src="https://github.com/user-attachments/assets/fd514ff7-0f3b-4074-be84-6fdce73fa09c" width="600">

## 機能一覧

- タスクの追加、削除
- タスクの完了/未完了の切り替え

## 使用技術

- バックエンド

  - Python 3.12.4
  - Flask 3.1.0
  - Flask-SQLAlchemy 3.1.1
  - SQLite

- フロントエンド
  - HTML5
  - Tailwind CSS

## セットアップ

1. リポジトリのクローン

```bash
git clone https://github.com/m-oka-system/todo-python-flask-mysql.git
cd todo-python-flask-mysql
```

2. 仮想環境の作成と有効化

```bash
# 仮想環境の作成
python -m venv .venv

# 仮想環境の有効化
# Windows (cmd.exe)の場合
C:\> .venv\Scripts\activate.bat

# Windows (PowerShell)の場合
PS C:\> .venv\Scripts\Activate.ps1

# bash/zshの場合
$ source .venv/bin/activate
```

3. 依存パッケージのインストール

```bash
pip install -r requirements.txt
```

4. アプリケーションの起動

```bash
python app.py
```

5. ブラウザで以下の URL にアクセス

```
http://localhost:5000
```

## 使い方

1. タスクの追加

   - 入力フィールドにタスクを入力
   - 「追加」ボタンをクリックまたは Enter キーを押す

2. タスクの完了/未完了

   - タスクの左側のチェックボックスをクリック
   - 完了したタスクは取り消し線で表示されます

3. タスクの削除
   - タスクの右側のゴミ箱アイコンをクリック

## プロジェクト構造

```
todo-python-flask-mysql/
│
├── app.py                # アプリケーション
├── requirements.txt      # 依存パッケージリスト
├── instance/
│   └── todo.db           # SQLiteデータベース
└── templates/
    └── index.html        # テンプレートファイル
```
