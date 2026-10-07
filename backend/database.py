import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "memory.db")

def get_db_connection():
    os.makedirs(os.path.dirname(DB_PATH), exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()

    # Create tables
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS people (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        relationship TEXT NOT NULL,
        lives_in TEXT,
        usually_calls TEXT
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS memories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        person_id INTEGER,
        content TEXT NOT NULL,
        FOREIGN KEY (person_id) REFERENCES people(id)
    )
    """)

    cursor.execute("""
    CREATE TABLE IF NOT EXISTS reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        scheduled_time TEXT NOT NULL,
        enabled INTEGER DEFAULT 1
    )
    """)

    # Seed data if empty
    cursor.execute("SELECT COUNT(*) FROM people")
    if cursor.fetchone()[0] == 0:
        # Seed People
        people_data = [
            (1, "Priya", "Daughter", "Bangalore", "Evening"),
            (2, "Arun", "Son", "Nearby", None),
            (3, "Dr. Sharma", "Family doctor", None, None)
        ]
        cursor.executemany("""
        INSERT INTO people (id, name, relationship, lives_in, usually_calls)
        VALUES (?, ?, ?, ?, ?)
        """, people_data)

        # Seed Memories
        memories_data = [
            (1, "Priya is the user's daughter."),
            (1, "Priya lives in Bangalore."),
            (1, "Priya usually calls in the evening."),
            (2, "Arun is the user's son."),
            (2, "Arun lives nearby."),
            (3, "Dr. Sharma is the user's family doctor."),
            (3, "Dr. Sharma has a clinic appointment at 11:00 AM.")
        ]
        cursor.executemany("""
        INSERT INTO memories (person_id, content)
        VALUES (?, ?)
        """, memories_data)

        # Seed Reminder
        cursor.execute("""
        INSERT INTO reminders (title, scheduled_time, enabled)
        VALUES (?, ?, ?)
        """, ("Doctor appointment", "11:00 AM", 1))

    conn.commit()
    conn.close()

def get_all_people():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM people")
    people = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return people

def get_person_by_name(name: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM people WHERE LOWER(name) = LOWER(?)", (name,))
    row = cursor.fetchone()
    conn.close()
    return dict(row) if row else None

def get_all_memories():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT memories.id, memories.person_id, memories.content, people.name as person_name FROM memories LEFT JOIN people ON memories.person_id = people.id")
    memories = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return memories

def get_all_reminders():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, title, scheduled_time as time FROM reminders WHERE enabled = 1")
    reminders = [dict(row) for row in cursor.fetchall()]
    conn.close()
    return reminders
