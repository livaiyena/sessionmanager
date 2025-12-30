"""
whitelist management for protected applications
"""

from pathlib import Path
from typing import List, Set

from sessionmanager.config import WHITELIST_FILE, DEFAULT_WHITELIST, DATA_DIR


class Whitelist:
    """manages list of applications that should not be terminated"""
    
    @staticmethod
    def load() -> Set[str]:
        """load whitelist from file or use defaults
        
        returns:
            set of protected application class names
        """
        try:
            if WHITELIST_FILE.exists():
                with open(WHITELIST_FILE, 'r') as f:
                    apps = [line.strip() for line in f if line.strip() and not line.startswith('#')]
                    return set(apps)
            else:
                # create default whitelist file
                Whitelist.save(DEFAULT_WHITELIST)
                return set(DEFAULT_WHITELIST)
        except (IOError, OSError) as e:
            print(f"error loading whitelist, using defaults: {e}")
            return set(DEFAULT_WHITELIST)
    
    @staticmethod
    def save(apps: List[str]):
        """save whitelist to file
        
        args:
            apps: list of application class names to protect
        """
        try:
            DATA_DIR.mkdir(parents=True, exist_ok=True)
            with open(WHITELIST_FILE, 'w') as f:
                f.write("# applications that will never be terminated by session enforcement\n")
                f.write("# one application class per line\n\n")
                for app in sorted(apps):
                    f.write(f"{app}\n")
        except (IOError, OSError) as e:
            print(f"error saving whitelist: {e}")
    
    @staticmethod
    def add(app_class: str) -> bool:
        """add an application to the whitelist
        
        args:
            app_class: application class name to protect
            
        returns:
            True if added, False if already exists
        """
        apps = Whitelist.load()
        if app_class in apps:
            return False
        apps.add(app_class)
        Whitelist.save(list(apps))
        return True
    
    @staticmethod
    def remove(app_class: str) -> bool:
        """remove an application from the whitelist
        
        args:
            app_class: application class name to unprotect
            
        returns:
            True if removed, False if not found
        """
        apps = Whitelist.load()
        if app_class not in apps:
            return False
        apps.remove(app_class)
        Whitelist.save(list(apps))
        return True
    
    @staticmethod
    def list_apps() -> List[str]:
        """get sorted list of whitelisted applications
        
        returns:
            sorted list of protected application class names
        """
        return sorted(Whitelist.load())
    
    @staticmethod
    def is_protected(app_class: str) -> bool:
        """check if an application is protected
        
        args:
            app_class: application class name to check
            
        returns:
            True if protected, False otherwise
        """
        return app_class in Whitelist.load()
