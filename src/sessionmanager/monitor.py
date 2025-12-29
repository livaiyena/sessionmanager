"""
hyprland window monitoring and activity tracking daemon
"""

import json
import os
import signal
import subprocess
import time
from datetime import datetime, timedelta
from typing import Optional, Dict

from sessionmanager.config import POLL_INTERVAL, DB_PATH
from sessionmanager.database import Database
from sessionmanager.enforcer import SessionEnforcer


class HyprlandMonitor:
    """monitors active windows in hyprland using hyprctl"""
    
    @staticmethod
    def get_active_window() -> Optional[Dict]:
        """get information about the currently active window"""
        try:
            result = subprocess.run(
                ['hyprctl', 'activewindow', '-j'],
                capture_output=True,
                text=True,
                timeout=2
            )
            
            if result.returncode != 0:
                return None
            
            data = json.loads(result.stdout)
            
            # check if there is actually an active window
            if not data.get('class'):
                return None
            
            return {
                'class': data.get('class', 'unknown'),
                'title': data.get('title', 'unknown'),
                'pid': data.get('pid', 0)
            }
        except (subprocess.TimeoutExpired, subprocess.CalledProcessError, json.JSONDecodeError, FileNotFoundError):
            return None


class MonitorDaemon:
    """background daemon that monitors window activity"""
    
    def __init__(self):
        self.db = Database(DB_PATH)
        self.running = True
        signal.signal(signal.SIGTERM, self._handle_signal)
        signal.signal(signal.SIGINT, self._handle_signal)
    
    def _handle_signal(self, signum, frame):
        """handle termination signals gracefully"""
        print("\nreceived shutdown signal, stopping monitor")
        self.running = False
    
    def run(self):
        """main monitoring loop"""
        print("starting activity monitor")
        print(f"polling interval: {POLL_INTERVAL} seconds")
        print(f"database: {DB_PATH}")
        
        last_window = None
        
        while self.running:
            try:
                # get current window
                window = HyprlandMonitor.get_active_window()
                
                if window:
                    # check if window changed to avoid duplicate logs
                    window_key = (window['class'], window['title'], window['pid'])
                    if window_key != last_window:
                        # determine current topic
                        active_session = self.db.get_active_session()
                        
                        if active_session:
                            topic = active_session['topic']
                            session_id = active_session['id']
                            
                            # track pid for enforcement
                            self.db.track_session_pid(session_id, window['pid'], window['class'])
                            
                            # check if session expired
                            start_time = datetime.fromisoformat(active_session['start_time'])
                            duration = timedelta(minutes=active_session['duration_minutes'])
                            if datetime.now() >= start_time + duration:
                                print(f"\nsession '{topic}' expired, enforcing termination")
                                self._enforce_session(session_id)
                        else:
                            topic = "Others"
                        
                        # log activity
                        self.db.log_activity(
                            window['class'],
                            window['title'],
                            topic,
                            window['pid']
                        )
                        
                        last_window = window_key
                
                time.sleep(POLL_INTERVAL)
            
            except Exception as e:
                print(f"error in monitoring loop: {e}")
                time.sleep(POLL_INTERVAL)
        
        self.db.close()
        print("monitor stopped")
    
    def _enforce_session(self, session_id: int):
        """enforce session expiration by terminating tracked pids"""
        pids = self.db.get_session_pids(session_id)
        self.db.end_session(session_id, 'expired')
        SessionEnforcer.terminate_pids(pids)
