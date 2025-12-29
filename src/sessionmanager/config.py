# session manager configuration constants

from pathlib import Path

# polling configuration
POLL_INTERVAL = 3  # seconds between window checks

# file paths
DATA_DIR = Path.home() / ".local" / "share" / "sessionmanager"
DB_PATH = DATA_DIR / "activity.db"
PID_FILE = DATA_DIR / "monitor.pid"
WHITELIST_FILE = DATA_DIR / "whitelist.txt"

# enforcement configuration
TERM_WAIT_SECONDS = 3  # wait time before sigkill after sigterm

# default whitelist: applications that should never be terminated
DEFAULT_WHITELIST = [
    'Hyprland',
    'systemd',
    'dbus',
    'waybar',
    'dunst',
]
