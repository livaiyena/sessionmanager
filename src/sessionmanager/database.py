"""
database operations for activity tracking and session management
"""

import sqlite3
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, Dict, List, Tuple

from sessionmanager.config import POLL_INTERVAL


class Database:
    """handles all database operations for activity tracking and session management"""
    
    def __init__(self, db_path: Path):
        """initialize database connection and create tables if needed"""
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self.conn = sqlite3.connect(str(db_path))
        self.conn.row_factory = sqlite3.Row
        self._init_tables()
    
    def _init_tables(self):
        """create database schema if tables do not exist"""
        cursor = self.conn.cursor()
        
        # activities table: logs every window focus event
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS activities (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                app_class TEXT NOT NULL,
                window_title TEXT NOT NULL,
                topic TEXT NOT NULL,
                pid INTEGER NOT NULL
            )
        """)
        
        # sessions table: tracks work sessions
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS sessions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                topic TEXT NOT NULL,
                description TEXT NOT NULL,
                start_time TEXT NOT NULL,
                duration_minutes INTEGER NOT NULL,
                end_time TEXT,
                status TEXT NOT NULL DEFAULT 'active'
            )
        """)
        
        # session_pids table: tracks which processes were accessed during a session
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS session_pids (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                session_id INTEGER NOT NULL,
                pid INTEGER NOT NULL,
                app_class TEXT NOT NULL,
                first_seen TEXT NOT NULL,
                FOREIGN KEY (session_id) REFERENCES sessions(id)
            )
        """)
        
        # macros table: stores reusable session templates
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS macros (
                name TEXT PRIMARY KEY,
                topic TEXT NOT NULL,
                description TEXT NOT NULL,
                duration_minutes INTEGER NOT NULL,
                created_at TEXT NOT NULL
            )
        """)
        
        self.conn.commit()
    
    def __enter__(self):
        """context manager entry - returns self for use in with statements"""
        return self
    
    def __exit__(self, exc_type, exc_val, exc_tb):
        """context manager exit - ensures database is properly closed
        
        args:
            exc_type: exception type if an error occurred
            exc_val: exception value if an error occurred
            exc_tb: exception traceback if an error occurred
        """
        self.close()
        return False  # dont suppress exceptions
    
    def log_activity(self, app_class: str, window_title: str, topic: str, pid: int):
        """log a window focus event to the database
        
        args:
            app_class: application class name
            window_title: window title text
            topic: session topic or 'Others'
            pid: process id
        """
        try:
            cursor = self.conn.cursor()
            cursor.execute("""
                INSERT INTO activities (timestamp, app_class, window_title, topic, pid)
                VALUES (?, ?, ?, ?, ?)
            """, (datetime.now().isoformat(), app_class, window_title, topic, pid))
            self.conn.commit()
        except sqlite3.Error as e:
            print(f"error logging activity: {e}")
    
    def get_last_activity(self) -> Optional[Dict]:
        """get the most recent activity logged
        
        returns:
            dict with activity data or None if no activities exist
        """
        try:
            cursor = self.conn.cursor()
            cursor.execute("""
                SELECT * FROM activities ORDER BY id DESC LIMIT 1
            """)
            row = cursor.fetchone()
            return dict(row) if row else None
        except sqlite3.Error as e:
            print(f"error getting last activity: {e}")
            return None
    
    def create_session(self, topic: str, description: str, duration_minutes: int) -> int:
        """create a new work session and return its id
        
        args:
            topic: session topic/category
            description: detailed description
            duration_minutes: session duration in minutes
            
        returns:
            session id of created session
        """
        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT INTO sessions (topic, description, start_time, duration_minutes, status)
            VALUES (?, ?, ?, ?, 'active')
        """, (topic, description, datetime.now().isoformat(), duration_minutes))
        self.conn.commit()
        return cursor.lastrowid
    
    def get_active_session(self) -> Optional[Dict]:
        """get the currently active session if one exists"""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT * FROM sessions WHERE status = 'active' ORDER BY id DESC LIMIT 1
        """)
        row = cursor.fetchone()
        return dict(row) if row else None
    
    def end_session(self, session_id: int, status: str = 'completed'):
        """mark a session as ended"""
        cursor = self.conn.cursor()
        cursor.execute("""
            UPDATE sessions SET end_time = ?, status = ? WHERE id = ?
        """, (datetime.now().isoformat(), status, session_id))
        self.conn.commit()
    
    def track_session_pid(self, session_id: int, pid: int, app_class: str):
        """record that a pid was accessed during a session"""
        cursor = self.conn.cursor()
        # check if already tracked
        cursor.execute("""
            SELECT id FROM session_pids WHERE session_id = ? AND pid = ?
        """, (session_id, pid))
        if cursor.fetchone():
            return
        
        cursor.execute("""
            INSERT INTO session_pids (session_id, pid, app_class, first_seen)
            VALUES (?, ?, ?, ?)
        """, (session_id, pid, app_class, datetime.now().isoformat()))
        self.conn.commit()
    
    def get_session_pids(self, session_id: int) -> List[Tuple[int, str]]:
        """get all pids tracked for a session"""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT pid, app_class FROM session_pids WHERE session_id = ?
        """, (session_id,))
        return [(row['pid'], row['app_class']) for row in cursor.fetchall()]
    
    def create_macro(self, name: str, topic: str, description: str, duration_minutes: int):
        """save a reusable session template"""
        cursor = self.conn.cursor()
        cursor.execute("""
            INSERT OR REPLACE INTO macros (name, topic, description, duration_minutes, created_at)
            VALUES (?, ?, ?, ?, ?)
        """, (name, topic, description, duration_minutes, datetime.now().isoformat()))
        self.conn.commit()
    
    def get_macro(self, name: str) -> Optional[Dict]:
        """retrieve a macro by name"""
        cursor = self.conn.cursor()
        cursor.execute("SELECT * FROM macros WHERE name = ?", (name,))
        row = cursor.fetchone()
        return dict(row) if row else None
    
    def list_macros(self) -> List[Dict]:
        """get all saved macros"""
        cursor = self.conn.cursor()
        cursor.execute("SELECT * FROM macros ORDER BY name")
        return [dict(row) for row in cursor.fetchall()]
    
    def delete_macro(self, name: str):
        """remove a macro"""
        cursor = self.conn.cursor()
        cursor.execute("DELETE FROM macros WHERE name = ?", (name,))
        self.conn.commit()
    
    def get_daily_report(self, date: str = None) -> List[Dict]:
        """get activity summary for a specific date"""
        if date is None:
            date = datetime.now().date().isoformat()
        
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT topic, app_class, COUNT(*) * ? as seconds
            FROM activities
            WHERE DATE(timestamp) = ?
            GROUP BY topic, app_class
            ORDER BY topic, seconds DESC
        """, (POLL_INTERVAL, date))
        return [dict(row) for row in cursor.fetchall()]
    
    def get_weekly_report(self) -> List[Dict]:
        """get activity summary for the past 7 days"""
        week_ago = (datetime.now() - timedelta(days=7)).date().isoformat()
        
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT topic, app_class, COUNT(*) * ? as seconds
            FROM activities
            WHERE DATE(timestamp) >= ?
            GROUP BY topic, app_class
            ORDER BY topic, seconds DESC
        """, (POLL_INTERVAL, week_ago))
        return [dict(row) for row in cursor.fetchall()]
    
    def get_session_history(self, limit: int = 10) -> List[Dict]:
        """get recent sessions"""
        cursor = self.conn.cursor()
        cursor.execute("""
            SELECT * FROM sessions ORDER BY id DESC LIMIT ?
        """, (limit,))
        return [dict(row) for row in cursor.fetchall()]
    
    
    def prune_activities(self, days: int) -> int:
        """delete activities older than specified days
        
        args:
            days: number of days to keep
            
        returns:
            number of rows deleted
        """
        cutoff = (datetime.now() - timedelta(days=days)).isoformat()
        cursor = self.conn.cursor()
        cursor.execute("DELETE FROM activities WHERE timestamp < ?", (cutoff,))
        deleted = cursor.rowcount
        self.conn.commit()
        return deleted

    def close(self):
        """close database connection"""
        self.conn.close()
