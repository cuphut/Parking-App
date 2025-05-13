import sqlite3

def create_plate_db():
    conn = sqlite3.connect('database/plates.db')
    cursor = conn.cursor()
    
    # Tạo bảng valid_plates với đầy đủ cột
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS valid_plates (
            plate TEXT PRIMARY KEY,
            name TEXT,
            company TEXT
        )
    ''')
    
    conn.commit()
    conn.close()

def add_plate_to_db(plate, name, company):
    conn = sqlite3.connect('database/plates.db')
    cursor = conn.cursor()

    # Chèn biển số mới vào bảng
    cursor.execute("INSERT INTO valid_plates (plate, name, company) VALUES (?, ?, ?)", (plate, name, company))
    
    conn.commit()
    conn.close()

def delete_plate(plate):
    conn = sqlite3.connect('database/plates.db')
    cursor = conn.cursor()

    # Xóa bản ghi có biển số khớp
    cursor.execute("DELETE FROM valid_plates WHERE plate = ?", (plate,))

    conn.commit()
    conn.close()
    print(f"✅ Đã xóa biển số: {plate}")

def get_plate_info(plate):
    conn = sqlite3.connect('database/plates.db')
    cursor = conn.cursor()

    # Lấy thông tin người và công ty từ biển số
    cursor.execute("SELECT name, company, plate FROM valid_plates WHERE plate = ?", (plate,))
    result = cursor.fetchone()

    conn.close()
    return result

def drop_table():
    # Kết nối tới cơ sở dữ liệu
    conn = sqlite3.connect('database/plates.db')
    cursor = conn.cursor()
    
    # Xoá bảng valid_plates nếu nó tồn tại
    cursor.execute("DROP TABLE IF EXISTS valid_plates")
    
    # Commit và đóng kết nối
    conn.commit()
    conn.close()

def view_all_plates():
    conn = sqlite3.connect("database/plates.db")
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM valid_plates")
    rows = cursor.fetchall()
    conn.close()

    print("📋 DANH SÁCH BIỂN SỐ TRONG DATABASE:")
    for row in rows:
        print(f"Biển số: {row[0]}, Ten: {row[1]}, Ten cong ty: {row[2]}")