# Session Manager

A comprehensive CLI-based activity tracker and session manager for Arch Linux running Hyprland (Wayland). Track productivity, manage focused work sessions, and enforce time limits with automatic application termination.

## Features

- **Automatic Activity Tracking**: Background daemon monitors active windows via `hyprctl`
- **Work Sessions**: Create focused sessions with topics, descriptions, and time limits
- **Session Enforcement**: Automatically terminates applications when session timer expires
- **Macro System**: Save reusable session templates for quick access
- **Activity Reports**: View daily and weekly summaries of time spent per application
- **Zero Dependencies**: Pure Python 3 with standard library only

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

### Manual Installation (Development)

For development or if you prefer manual installation:

1. Clone or download this repository:
```bash
cd ~/Documents/sessionmanager
```

2. Make the script executable:
```bash
chmod +x sessionmanager
```

3. Run the installation script for aliases:
```bash
chmod +x install.sh
./install.sh
source ~/.bashrc  # for bash
# or
source ~/.zshrc   # for zsh
# or
source ~/.config/fish/config.fish  # for fish
```

The installer automatically detects and configures Bash, Zsh, and Fish shells.

4. Manually start the monitor daemon:
```bash
sessionmanager monitor start
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
│       ├── __init__.py          # Package metadata
│       ├── config.py            # Configuration constants
│       ├── database.py          # SQLite operations
│       ├── monitor.py           # Hyprland monitoring daemon
│       ├── enforcer.py          # PID termination logic
│       └── cli.py               # CLI interface
├── sessionmanager               # Main entry point (binary)
├── README.md                    # This file
├── install.sh                   # Alias installer
└── sessionmanager.service       # Systemd service file
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
- **database.py**: Complete SQLite abstraction layer
- **monitor.py**: Hyprland integration and daemon logic
- **enforcer.py**: Session enforcement and PID termination
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
cd ~/Documents/sessionmanager
git pull origin main
./install.sh
```

## Security Considerations

- The session enforcement feature will **forcefully terminate applications**, which may result in data loss if users have unsaved work
- The daemon runs with user privileges and can only terminate processes owned by the user
- PIDs are tracked per session, so only applications accessed during a specific session are terminated
- Consider adding important applications to a whitelist if you modify the code

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
