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
        """load whitelist from file or use defaults"""
        if WHITELIST_FILE.exists():
            with open(WHITELIST_FILE, 'r') as f:
                apps = [line.strip() for line in f if line.strip() and not line.startswith('#')]
                return set(apps)
        else:
            # create default whitelist file
            Whitelist.save(DEFAULT_WHITELIST)
            return set(DEFAULT_WHITELIST)
    
    @staticmethod
    def save(apps: List[str]):
        """save whitelist to file"""
        DATA_DIR.mkdir(parents=True, exist_ok=True)
        with open(WHITELIST_FILE, 'w') as f:
            f.write("# applications that will never be terminated by session enforcement\n")
            f.write("# one application class per line\n\n")
            for app in sorted(apps):
                f.write(f"{app}\n")
    
    @staticmethod
    def add(app_class: str) -> bool:
        """add an application to the whitelist"""
        apps = Whitelist.load()
        if app_class in apps:
            return False
        apps.add(app_class)
        Whitelist.save(list(apps))
        return True
    
    @staticmethod
    def remove(app_class: str) -> bool:
        """remove an application from the whitelist"""
        apps = Whitelist.load()
        if app_class not in apps:
            return False
        apps.remove(app_class)
        Whitelist.save(list(apps))
        return True
    
    @staticmethod
    def list_apps() -> List[str]:
        """get sorted list of whitelisted applications"""
        return sorted(Whitelist.load())
    
    @staticmethod
    def is_protected(app_class: str) -> bool:
        """check if an application is protected"""
        return app_class in Whitelist.load()
