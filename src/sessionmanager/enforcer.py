"""
session enforcement and process termination
"""

import os
import signal
import time
from typing import List, Tuple

from sessionmanager.config import TERM_WAIT_SECONDS
from sessionmanager.whitelist import Whitelist


class SessionEnforcer:
    """handles session timer enforcement and pid termination"""
    
    @staticmethod
    def terminate_pids(pids_with_apps: List[Tuple[int, str]]):
        """terminate a list of pids gracefully then forcefully if needed
        
        args:
            pids_with_apps: list of tuples containing (pid, app_class) pairs
            
        process:
            1. filters out whitelisted applications
            2. sends sigterm to all processes
            3. waits TERM_WAIT_SECONDS
            4. sends sigkill to any remaining processes
        """
        if not pids_with_apps:
            return
        
        # filter out whitelisted applications
        whitelist = Whitelist.load()
        protected = []
        to_terminate = []
        
        for pid, app_class in pids_with_apps:
            if app_class in whitelist:
                protected.append((pid, app_class))
            else:
                to_terminate.append((pid, app_class))
        
        # report protected apps
        if protected:
            print(f"\nprotected applications (will not terminate):")
            for pid, app_class in protected:
                print(f"  {app_class} (pid {pid})")
        
        if not to_terminate:
            print("\nno applications to terminate (all are protected)")
            return
        
        print(f"\nterminating {len(to_terminate)} processes from session")
        
        # first pass: send sigterm to all processes
        alive_pids = []
        for pid, app_class in to_terminate:
            try:
                os.kill(pid, signal.SIGTERM)
                alive_pids.append((pid, app_class))
                print(f"  sent sigterm to {app_class} (pid {pid})")
            except ProcessLookupError:
                print(f"  process {app_class} (pid {pid}) already terminated")
            except PermissionError:
                print(f"  permission denied for {app_class} (pid {pid})")
        
        if not alive_pids:
            return
        
        # wait before forceful termination
        print(f"waiting {TERM_WAIT_SECONDS} seconds before sigkill")
        time.sleep(TERM_WAIT_SECONDS)
        
        # second pass: send sigkill to remaining processes
        for pid, app_class in alive_pids:
            try:
                os.kill(pid, signal.SIGKILL)
                print(f"  sent sigkill to {app_class} (pid {pid})")
            except ProcessLookupError:
                print(f"  process {app_class} (pid {pid}) already terminated")
            except PermissionError:
                print(f"  permission denied for {app_class} (pid {pid})")

