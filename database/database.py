import sqlite3
from datetime import datetime

DB_PATH = "database/parking_app.db"

#Vehicle
def create_vehicle_db():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('''
        CREATE TABLE IF NOT EXISTS vehicle_info (
            plate TEXT PRIMARY KEY,
            name TEXT,
            companyName TEXT,
            companyFloor TEXT,
            phone TEXT
        )
    ''')
    conn.commit()
    conn.close()

def add_vehicle_to_db(plate, name, company_name, company_floor, phone):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute('''
        INSERT OR REPLACE INTO vehicle_info (plate, name, companyName, companyFloor, phone)
        VALUES (?, ?, ?, ?, ?)
    ''', (plate, name, company_name, company_floor, phone))

    conn.commit()
    conn.close()

def delete_vehicle_from_db(plate):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("DELETE FROM vehicle_info WHERE plate = ?", (plate,))
    conn.commit()
    conn.close()

def get_vehicle_info(plate):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM vehicle_info WHERE plate = ?", (plate,))
    result = cursor.fetchone()
    conn.close()
    return result

def view_all_vehicle():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM vehicle_info")
    rows = cursor.fetchall()
    conn.close()
    return rows

#Parking

def create_parking_table():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    # Bật hỗ trợ foreign key
    cursor.execute("PRAGMA foreign_keys = ON")

    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Parking (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            plate TEXT,
            timeIn TEXT,
            timeOut TEXT,
            FOREIGN KEY (plate) REFERENCES vehicle_info(plate)
                ON DELETE CASCADE
                ON UPDATE CASCADE
        )
    """)
    conn.commit()
    conn.close()

def add_parking_entry(plate: str, time_in: str):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    cursor.execute("PRAGMA foreign_keys = ON")

    # 1. Kiểm tra xem có bản ghi nào chưa có timeOut không
    cursor.execute(
        "SELECT id FROM Parking WHERE plate = ? AND timeOut IS NULL",
        (plate,)
    )
    existing_entry = cursor.fetchone()

    if existing_entry:
        # 2. Nếu có, cập nhật timeOut (xe ra)
        cursor.execute(
            "UPDATE Parking SET timeOut = ? WHERE id = ?",
            (time_in, existing_entry[0])
        )
    else:
        # 3. Nếu không, thêm bản ghi mới (xe vào)
        cursor.execute(
            "INSERT INTO Parking (plate, timeIn, timeOut) VALUES (?, ?, NULL)",
            (plate, time_in)
        )
        
    conn.commit()
    conn.close()

def view_all_parking():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("""
        SELECT Parking.plate, Vehicle_Info.name, Vehicle_Info.companyName,
               Vehicle_Info.companyFloor, Vehicle_Info.phone,
               Parking.timeIn, Parking.timeOut
        FROM Parking
        LEFT JOIN Vehicle_Info ON Parking.plate = Vehicle_Info.plate
        ORDER BY Parking.timeIn DESC
    """)
    results = cursor.fetchall()
    conn.close()
    return results


def delete_parking_from_db(plate):
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()

    cursor.execute("DELETE FROM Parking WHERE plate = ?", (plate,))
    conn.commit()
    conn.close()