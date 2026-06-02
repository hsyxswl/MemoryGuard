CREATE TABLE IF NOT EXISTS medicines (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    take_time TEXT NOT NULL,
    dosage TEXT,
    note TEXT
);
CREATE TABLE IF NOT EXISTS med_log (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    med_name TEXT,
    taken_date TEXT,
    status TEXT DEFAULT 'pending',
    confirmed_at TEXT,
    UNIQUE(med_name, taken_date)
);
