# Session Manager

A comprehensive CLI-based activity tracker and session manager for Arch Linux running Hyprland (Wayland). Track productivity, manage focused work sessions, and enforce time limits with automatic application termination.

## Features

- **Automatic Activity Tracking**: Background daemon monitors active windows via `hyprctl`
- **Work Sessions**: Create focused sessions with topics, descriptions, and time limits
- **Session Enforcement**: Automatically terminates applications when session timer expires
- **Macro System**: Save reusable session templates for quick access
- **Activity Reports**: View daily and weekly summaries of time spent per application
- **Application Whitelist**: Protect critical applications from session enforcement
- **Zero Dependencies**: Pure Python 3 with standard library only
- **Robust Error Handling**: Graceful degradation and comprehensive error messages

## Requirements

- Arch Linux with Hyprland (Wayland compositor)
- Python 3.8 or higher
- `hyprctl` command available (comes with Hyprland)

## Installation

### AUR Installation (Recommended)

Install from the Arch User Repository using `yay` or another AUR helper:

```bash
# install the package
yay -S sessionmanager

# enable and start the systemd service
systemctl --user enable sessionmanager.service
systemctl --user start sessionmanager.service

# check status
systemctl --user status sessionmanager.service
```

The package installs everything system-wide:
- Command: `sessionmanager`
- Python modules: `/usr/lib/python3.12/site-packages/sessionmanager/`
- Completions: Bash, Zsh, and Fish (automatically configured)
- Systemd service: `/usr/lib/systemd/user/sessionmanager.service`
- Documentation: `/usr/share/doc/sessionmanager/`

### Manual Installation (Development/Testing)

> **Note:** For most users, the AUR installation is recommended. Manual installation is primarily for development or testing purposes.

The manual installation script installs everything to `~/.local` for user-level access.

#### Quick Installation

1. Clone this repository:
```bash
git clone https://github.com/livaiyena/sessionmanager.git
cd sessionmanager
```

2. Run the installation script:
```bash
chmod +x install.sh
./install.sh
```

This will install:
- SessionManager binary → `~/.local/bin/sessionmanager`
- Python package → `~/.local/lib/python3.x/site-packages/`
- Systemd service → `~/.config/systemd/user/sessionmanager.service`
- Shell completions → Bash, Zsh, and Fish
- Documentation → `~/.local/share/doc/sessionmanager/`

3. Ensure `~/.local/bin` is in your PATH:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

4. Start the service:
```bash
# Option 1: Manual start
sessionmanager monitor start

# Option 2: Use systemd (recommended)
systemctl --user enable sessionmanager
systemctl --user start sessionmanager
```

#### Alternative: Pip Installation

For development with editable install:
```bash
git clone https://github.com/livaiyena/sessionmanager.git
cd sessionmanager
pip install --user -e .
```

#### Uninstall

To remove the manual installation:
```bash
chmod +x uninstall.sh
./uninstall.sh
```

## Usage

### Monitor Daemon

The monitor daemon runs in the background and tracks window activity.

```bash
sessionmanager monitor start
sessionmanager monitor status
sessionmanager monitor stop
```

### Work Sessions

Create focused work sessions with automatic enforcement when time expires.

```bash
sessionmanager session start --topic "Development" --description "API implementation" --duration 120
sessionmanager session current
sessionmanager session stop
```

**Important**: When a session timer expires, all applications that were focused during that session will be automatically terminated (graceful SIGTERM followed by SIGKILL if needed), except for whitelisted applications.

### Application Whitelist

Protect critical applications from being terminated when sessions expire.

```bash
sessionmanager whitelist list
sessionmanager whitelist add --app firefox
sessionmanager whitelist remove --app firefox
```

Default protected applications:
- Hyprland
- systemd
- dbus
- waybar
- dunst

### Macros (Session Templates)

Save frequently used session configurations as macros for quick access.

```bash
# create a macro
sessionmanager macro create \
  --name coding \
  --topic "Development" \
  --description "Coding session" \
  --duration 90

# list all macros
sessionmanager macro list

# start session using macro
sessionmanager macro run --name coding

# alternative shorthand
sessionmanager session start --macro coding

# delete macro
sessionmanager macro delete --name coding
```



### Activity Reports

View summaries of your tracked activity.

```bash
# daily report (today)
sessionmanager report daily

# weekly report (past 7 days)
sessionmanager report weekly
```



## Project Structure

```
sessionmanager/
├── src/
│   └── sessionmanager/          # Python package with all modules
│       ├── __init__.py          # Package metadata (v0.0.5)
│       ├── config.py            # Configuration constants
│       ├── database.py          # SQLite operations with context manager
│       ├── monitor.py           # Hyprland monitoring daemon
│       ├── enforcer.py          # PID termination logic
│       ├── whitelist.py         # Protected applications management
│       └── cli.py               # CLI interface
├── completions/                 # Shell completion scripts
│   ├── sessionmanager.bash      # Bash completion
│   ├── _sessionmanager          # Zsh completion
│   └── sessionmanager.fish      # Fish completion
├── aur-sessionmanager/          # AUR package files
│   ├── PKGBUILD                 # AUR package build script
│   └── .SRCINFO                 # AUR package metadata
├── sessionmanager               # Main entry point (binary)
├── sessionmanager.service       # Systemd user service file
├── install.sh                   # Full installation script
├── uninstall.sh                 # Removal script
├── setup.py                     # Python package setup
├── PKGBUILD                     # Main package build script
├── CHANGELOG.md                 # Version history
├── README.md                    # This file
└── LICENSE                      # GPL-3.0 license
```

## How It Works

### Activity Tracking

The monitor daemon checks the active window every 3 seconds using `hyprctl activewindow -j`. Each focus event is logged to an SQLite database with:
- Timestamp
- Application class (e.g., firefox, kitty)
- Window title
- Current topic (session topic or "Others")
- Process ID (PID)

### Session Management

When you start a session:
1. The session is created with a start time and duration
2. All subsequent activity is logged under that session's topic
3. Every process (PID) you focus is tracked in the database
4. When the timer expires, the daemon:
   - Sends SIGTERM to all tracked PIDs
   - Waits 3 seconds
   - Sends SIGKILL to any remaining processes

### Data Storage

All data is stored in `~/.local/share/sessionmanager/activity.db` using SQLite with four tables:
- `activities`: Every window focus event
- `sessions`: Work session metadata
- `session_pids`: Which PIDs were accessed during each session
- `macros`: Saved session templates

### Modular Architecture

The application is organized into focused modules:
- **config.py**: Central configuration with all constants
- **database.py**: Complete SQLite abstraction layer with context manager support
- **monitor.py**: Hyprland integration and daemon logic
- **enforcer.py**: Session enforcement and PID termination
- **whitelist.py**: Protected applications management with file-based storage
- **cli.py**: All command-line interface implementations
- **sessionmanager**: Lightweight entry point with argparse

## Configuration

You can modify these constants in `src/sessionmanager/config.py`:

```python
POLL_INTERVAL = 3  # seconds between window checks
DATA_DIR = Path.home() / ".local" / "share" / "sessionmanager"
DB_PATH = DATA_DIR / "activity.db"
PID_FILE = DATA_DIR / "monitor.pid"
TERM_WAIT_SECONDS = 3  # wait before SIGKILL
```

## Troubleshooting

### Monitor not starting

Check if Hyprland is running:
```bash
hyprctl activewindow -j
```

If this fails, ensure you are in a Hyprland session.

### Applications not being terminated

The enforcement mechanism requires proper PID tracking. Some applications may:
- Spawn child processes with different PIDs
- Require elevated permissions
- Already be closed when enforcement runs

Check the monitor log output for termination details.

### Database locked errors

If you see database locking errors, ensure only one monitor daemon is running:
```bash
sessionmanager monitor status
sessionmanager monitor stop
```

### Stale PID file

If the daemon crashes, you may have a stale PID file:
```bash
rm ~/.local/share/sessionmanager/monitor.pid
```

The latest version (0.0.5+) includes improved PID file cleanup that prevents most stale file issues.

## Changelog

### Version 0.0.5 (2025-12-30)

**Critical Bug Fixes:**
- Fixed `sessionmanager.service` incorrect file paths that prevented systemd service from starting
- Removed problematic sys.path manipulation that could cause import conflicts
- Enhanced PID file cleanup with try-finally blocks to prevent stale files

**Code Quality Improvements:**
- Refactored duplicate report generation code (reduced ~45 lines)
- Added database context manager support for proper resource management
- Enhanced error handling across all modules (database, whitelist, enforcer)
- Improved error messages with detailed exception information

**Documentation:**
- Added comprehensive docstrings with parameter and return type documentation
- Enhanced install.sh with better error handling and user feedback
- Improved inline comments and code documentation

**Maintenance:**
- Maintained modular architecture and code structure
- Preserved all existing comments and functionality
- All modules passed syntax validation



## Example Workflow

```bash
# start monitoring (one time setup with systemd)
systemctl --user start sessionmanager

# or manually
sessionmanager monitor start

# create some macros for common tasks
sessionmanager macro create --name focus --topic "Deep Work" --description "Focused coding" --duration 120
sessionmanager macro create --name meeting --topic "Meetings" --description "Team sync" --duration 60

# start a session using a macro
sessionmanager macro run --name focus

# check current session
sessionmanager session current

# when done, end early
sessionmanager session stop

# view your daily productivity
sessionmanager report daily
```

## Updating

### AUR Installation

Updates are handled automatically with your system updates:

```bash
# update all packages including sessionmanager
yay -Syu

# update only sessionmanager
yay -S sessionmanager
```

### Manual Installation

```bash
cd /path/to/sessionmanager
git pull origin main
# Optionally reinstall completions
./install.sh
```

## Security Considerations

- The session enforcement feature will **forcefully terminate applications**, which may result in data loss if users have unsaved work
- The daemon runs with user privileges and can only terminate processes owned by the user
- PIDs are tracked per session, so only applications accessed during a specific session are terminated
- Use the built-in whitelist feature (`sessionmanager whitelist add`) to protect critical applications from termination
- Default protected applications include Hyprland, systemd, dbus, waybar, and dunst

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
