"""
Tạo lại food_database.db từ food_database.json
Chạy: python tool/create_food_db.py
"""

import json
import sqlite3
import os

def main():
    json_path = 'assets/database/food_database.json'
    db_path = 'assets/database/food_database.db'

    # Load JSON
    with open(json_path, 'r', encoding='utf-8') as f:
        foods = json.load(f)
    print(f"Loaded {len(foods)} food items from JSON")

    # Xóa DB cũ
    if os.path.exists(db_path):
        os.remove(db_path)
        print("Deleted existing database")

    # Tạo DB mới
    conn = sqlite3.connect(db_path)
    cur = conn.cursor()

    # Tạo bảng
    cur.execute('''
        CREATE TABLE IF NOT EXISTS foods (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            key TEXT NOT NULL UNIQUE,
            name TEXT NOT NULL,
            name_en TEXT NOT NULL,
            calories_per_100g REAL NOT NULL,
            glycemic_index INTEGER NOT NULL,
            protein REAL NOT NULL,
            carbs REAL NOT NULL,
            fat REAL NOT NULL,
            fiber REAL NOT NULL,
            category TEXT NOT NULL
        )
    ''')

    # Tạo indexes
    cur.execute('CREATE INDEX idx_foods_name ON foods(name)')
    cur.execute('CREATE INDEX idx_foods_name_en ON foods(name_en)')
    cur.execute('CREATE INDEX idx_foods_category ON foods(category)')
    cur.execute('CREATE INDEX idx_foods_key ON foods(key)')

    # Insert dữ liệu
    for food in foods:
        cur.execute('''
            INSERT OR REPLACE INTO foods (key, name, name_en, calories_per_100g, glycemic_index, protein, carbs, fat, fiber, category)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            food['key'],
            food['name'],
            food.get('name_en', ''),
            food.get('calories_per_100g', 0),
            food.get('glycemic_index', 50),
            food.get('protein', 0),
            food.get('carbs', 0),
            food.get('fat', 0),
            food.get('fiber', 0),
            food.get('category', 'Chưa phân loại'),
        ))

    conn.commit()

    # Verify
    cur.execute('SELECT COUNT(*) FROM foods')
    count = cur.fetchone()[0]
    print(f"\nDatabase created: {db_path}")
    print(f"Total records: {count}")

    # Liệt kê categories
    cur.execute('SELECT category, COUNT(*) as cnt FROM foods GROUP BY category ORDER BY cnt DESC')
    categories = cur.fetchall()
    print(f"\nCategories ({len(categories)}):")
    for cat, cnt in categories:
        print(f"  - {cat} ({cnt} items)")

    conn.close()
    print(f"\n✅ food_database.db created successfully!")

if __name__ == '__main__':
    main()
