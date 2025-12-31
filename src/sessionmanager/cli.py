"""
command line interface for session manager
"""

import json
import os
import signal
import time
from pathlib import Path
from datetime import datetime, timedelta

from sessionmanager.config import DB_PATH, PID_FILE
from sessionmanager.database import Database
from sessionmanager.monitor import MonitorDaemon
from sessionmanager.whitelist import Whitelist


class CLI:
    """command line interface for session manager"""
    
    def __init__(self):
        self.db = Database(DB_PATH)
    
    def monitor_start(self):
        """start the background monitoring daemon"""
        if PID_FILE.exists():
            try:
                with open(PID_FILE) as f:
                    old_pid = int(f.read().strip())
                os.kill(old_pid, 0)  # check if process exists
                print(f"monitor running (pid {old_pid})")
                return
            except (ProcessLookupError, ValueError):
                # stale pid file
                PID_FILE.unlink()
        
        # fork to background
        pid = os.fork()
        if pid > 0:
            # parent process
            PID_FILE.parent.mkdir(parents=True, exist_ok=True)
            with open(PID_FILE, 'w') as f:
                f.write(str(pid))
            print(f"monitor started (pid {pid})")
            return
        
        # child process: run daemon
        os.setsid()
        daemon = MonitorDaemon()
        daemon.run()
        sys.exit(0)
    
    def monitor_stop(self):
        """stop the background monitoring daemon"""
        if not PID_FILE.exists():
            print("monitor is not running")
            return
        
        try:
            with open(PID_FILE) as f:
                pid = int(f.read().strip())
            
            try:
                os.kill(pid, signal.SIGTERM)
                print(f"stopping monitor (pid {pid})")
                
                # wait for process to terminate
                for _ in range(10):
                    time.sleep(0.5)
                    try:
                        os.kill(pid, 0)
                    except ProcessLookupError:
                        break
                
                print("monitor stopped")
            
            except ProcessLookupError:
                print("monitor not found")
            except PermissionError:
                print(f"permission denied (pid {pid})")
        
        except ValueError as e:
            print(f"invalid pid file: {e}")
        
        finally:
            # always clean up pid file
            if PID_FILE.exists():
                PID_FILE.unlink()
    
    def monitor_status(self):
        """check if monitoring daemon is running"""
        if not PID_FILE.exists():
            print("monitor is not running")
            return
        
        try:
            with open(PID_FILE) as f:
                pid = int(f.read().strip())
            os.kill(pid, 0)
            print(f"monitor is running (pid {pid})")
        except (ProcessLookupError, ValueError):
            print("monitor is not running (stale pid file)")
            PID_FILE.unlink()
    
    def session_start(self, topic: str, description: str, duration: int, macro: str = None):
        """start a new work session"""
        # check if there is already an active session
        active = self.db.get_active_session()
        if active:
            print(f"active session: {active['topic']}")
            print("stop current session first")
            return
        
        # if using macro, load parameters
        if macro:
            macro_data = self.db.get_macro(macro)
            if not macro_data:
                print(f"macro '{macro}' not found")
                return
            topic = macro_data['topic']
            description = macro_data['description']
            duration = macro_data['duration_minutes']
            print(f"using macro: {macro}")
        
        session_id = self.db.create_session(topic, description, duration)
        end_time = datetime.now() + timedelta(minutes=duration)
        
        print(f"session: {topic}")
        print(f"desc: {description}")
        print(f"duration: {duration}m")
        print(f"expires: {end_time.strftime('%H:%M:%S')}")
    
    def session_stop(self):
        """manually end the current session"""
        active = self.db.get_active_session()
        if not active:
            print("no active session")
            return
        
        self.db.end_session(active['id'], 'stopped')
        print(f"stopped session: {active['topic']}")
    
    def session_current(self):
        """show information about the current session"""
        active = self.db.get_active_session()
        if not active:
            print("no active session")
            return
        
        start_time = datetime.fromisoformat(active['start_time'])
        duration = timedelta(minutes=active['duration_minutes'])
        end_time = start_time + duration
        time_remaining = end_time - datetime.now()
        
        print(f"topic: {active['topic']}")
        print(f"desc: {active['description']}")
        print(f"start: {start_time.strftime('%Y-%m-%d %H:%M:%S')}")
        print(f"duration: {active['duration_minutes']}m")
        print(f"expires: {end_time.strftime('%H:%M:%S')}")
        
        if time_remaining.total_seconds() > 0:
            mins = int(time_remaining.total_seconds() / 60)
            secs = int(time_remaining.total_seconds() % 60)
            print(f"remaining: {mins}m {secs}s")
        else:
            print("status: expired")
    
    def report_daily(self, json_output: bool = False):
        """show daily activity report"""
        data = self.db.get_daily_report()
        
        if json_output:
            self._print_json(data)
            return
        
        if not data:
            print("no activity logged today")
            return
        
        print("daily report")
        print("-" * 40)
        self._print_report(data)
    
    def report_weekly(self, json_output: bool = False):
        """show weekly activity report"""
        data = self.db.get_weekly_report()
        
        if json_output:
            self._print_json(data)
            return
        
        if not data:
            print("no activity logged in the past week")
            return
        
        print("weekly report (7 days)")
        print("-" * 40)
        self._print_report(data)
    
    def macro_list(self):
        """list all saved macros"""
        macros = self.db.list_macros()
        
        if not macros:
            print("no macros saved")
            return
        
        print("saved macros:")
        print("=" * 60)
        for macro in macros:
            print(f"{macro['name']}:")
            print(f"  topic: {macro['topic']}")
            print(f"  desc: {macro['description']}")
            print(f"  duration: {macro['duration_minutes']}m")
            print()
    
    def macro_create(self, name: str, topic: str, description: str, duration: int):
        """create a new macro template"""
        self.db.create_macro(name, topic, description, duration)
        print(f"created macro: {name}")
    
    def macro_delete(self, name: str):
        """delete a macro template"""
        if not self.db.get_macro(name):
            print(f"macro '{name}' not found")
            return
        
        self.db.delete_macro(name)
        print(f"deleted macro: {name}")
    
    def macro_run(self, name: str):
        """start a session using a macro template"""
        macro = self.db.get_macro(name)
        if not macro:
            print(f"macro '{name}' not found")
            return
        
        self.session_start(
            macro['topic'],
            macro['description'],
            macro['duration_minutes']
        )
    
    def whitelist_list(self):
        """list all protected applications"""
        apps = Whitelist.list_apps()
        
        if not apps:
            print("no applications in whitelist")
            return
        
        print("protected apps:")
        print("-" * 40)
        for app in apps:
            print(f"  {app}")
    
    def whitelist_add(self, app_class: str):
        """add an application to the whitelist"""
        if Whitelist.add(app_class):
            print(f"added {app_class} to whitelist")
        else:
            print(f"{app_class} is already in whitelist")
    
    def whitelist_remove(self, app_class: str):
        """remove an application from the whitelist"""
        if Whitelist.remove(app_class):
            print(f"removed {app_class} from whitelist")
        else:
            print(f"{app_class} is not in whitelist")
    
            print(f"{app_class} is not in whitelist")
    
    def cleanup(self, days: int):
        """cleanup old activity logs"""
        deleted = self.db.prune_activities(days)
        print(f"deleted {deleted} entries older than {days} days")
    
    def _print_report(self, data: list):
        """helper method to print formatted activity report
        
        args:
            data: list of activity entries with topic, app_class, and seconds
        """
        current_topic = None
        topic_total = 0
        
        for entry in data:
            if entry['topic'] != current_topic:
                if current_topic:
                    print(f"  total: {self._format_duration(topic_total)}")
                    print()
                current_topic = entry['topic']
                topic_total = 0
                print(f"{current_topic}:")
            
            topic_total += entry['seconds']
            duration = self._format_duration(entry['seconds'])
            print(f"  {entry['app_class']}: {duration}")
        
        if current_topic:
            print(f"  total: {self._format_duration(topic_total)}")
            
    @staticmethod
    def _print_json(data: list):
        """print data as json"""
        print(json.dumps(data, indent=2))
    
    @staticmethod
    def _format_duration(seconds: int) -> str:
        """format seconds as human readable duration
        
        args:
            seconds: duration in seconds
            
        returns:
            formatted string like '2h 30m 15s'
        """
        hours = seconds // 3600
        minutes = (seconds % 3600) // 60
        secs = seconds % 60
        
        parts = []
        if hours > 0:
            parts.append(f"{hours}h")
        if minutes > 0:
            parts.append(f"{minutes}m")
        if secs > 0 or not parts:
            parts.append(f"{secs}s")
        
        return " ".join(parts)
