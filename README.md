# sessionmanager

CLI activity tracker and session manager for Hyprland. Monitors active windows, tracks work sessions, and enforces time limits.

## Features

- **Tracking**: Background daemon monitors windows via `hyprctl`.
- **Sessions**: Timed work sessions with strict enforcement.
- **Enforcement**: Terminates non-whitelisted apps when session expires.
- **Macros**: Templates for recurring sessions.
- **Reports**: Daily and weekly activity summaries.
- **Whitelist**: Protect critical apps from termination.

## Installation

### AUR

```bash
yay -S sessionmanager
systemctl --user enable --now sessionmanager.service
```

### Manual

```bash
git clone https://github.com/livaiyena/sessionmanager.git
cd sessionmanager
./install.sh
sessionmanager monitor start
```

## Usage

### Daemon

```bash
sessionmanager monitor start
sessionmanager monitor status
sessionmanager monitor stop
```

### Sessions

```bash
# start session
sessionmanager session start --topic "Work" --description "coding" --duration 60

# check status
sessionmanager session current

# stop early
sessionmanager session stop
```

**Note**: Expired sessions terminate non-whitelisted apps.

### Macros

```bash
# create
sessionmanager macro create --name work --topic "Work" --description "coding" --duration 60

# run
sessionmanager macro run --name work
```

### Reports

```bash
sessionmanager report daily
sessionmanager report weekly
```

### Whitelist

Protect apps from enforcement.

```bash
sessionmanager whitelist add --app firefox
sessionmanager whitelist list
```

## Configuration

Edit `src/sessionmanager/config.py` to change:
- Poll interval
- Database path
- Timeouts

## License

GPL-3.0-or-later
