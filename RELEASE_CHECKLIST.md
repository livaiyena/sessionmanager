# Session Manager Release Checklist v0.0.1

## ✅ Pre-Release Checklist

- [x] Version updated to 0.0.1 in `src/sessionmanager/__init__.py`
- [x] PKGBUILD updated with version 0.0.1
- [x] PKGBUILD configured with GitHub source URL
- [x] Manual installations cleaned from system
  - [x] Monitor daemon stopped
  - [x] Bashrc cleaned
  - [x] Fish config cleaned
  - [x] Alias files removed
  - [x] Completions removed from ~/.config
- [x] .gitignore created
- [x] LICENSE created (MIT)

## 📋 Files Ready for GitHub

```
sessionmanager/
├── .gitignore
├── LICENSE
├── README.md
├── AUR_GUIDE.md
├── PKGBUILD
├── install.sh (for manual installation)
├── sessionmanager (entry point for system install)
├── session_manager.py (entry point for dev)
├── sessionmanager.service
├── completions/
│   ├── session_manager.bash
│   ├── _session_manager
│   └── session_manager.py.fish
└── src/
    └── sessionmanager/
        ├── __init__.py (v0.0.1)
        ├── config.py
        ├── database.py
        ├── monitor.py
        ├── enforcer.py
        ├── cli.py
        └── whitelist.py
```

## 🚀 GitHub Release Steps

### 1. Create Repository & Push
```bash
cd /home/livaiyena/Documents/niceideas/sessionmanager

# initialize git if needed
git init
git add .
git commit -m "initial release v0.0.1"

# add remote (replace USERNAME with your GitHub username)
git remote add origin https://github.com/USERNAME/sessionmanager.git

# push
git branch -M main
git push -u origin main
```

### 2. Create GitHub Release
- Go to: https://github.com/USERNAME/sessionmanager/releases/new
- Tag: `v0.0.1`
- Release title: `Session Manager v0.0.1 - Initial Release`
- Description:
```markdown
# Session Manager v0.0.1

Initial release of Session Manager - a CLI-based activity tracker and session manager for Hyprland on Arch Linux.

## Features
- 🕒 Automatic window activity tracking
- ⏱️ Focused work sessions with enforced timers
- 🛡️ Application whitelist for protected processes
- 📊 Daily and weekly activity reports
- 🔖 Macro system for session templates
- 🐚 Tab completion for Bash, Zsh, and Fish
- 🔄 Systemd service integration

## Installation
Available on AUR:
\`\`\`bash
yay -S sessionmanager
systemctl --user enable --now sessionmanager.service
\`\`\`

## Documentation
See [README.md](https://github.com/USERNAME/sessionmanager/blob/main/README.md)
```

### 3. Update PKGBUILD with Checksum
```bash
# download the tarball
wget https://github.com/USERNAME/sessionmanager/archive/v0.0.1.tar.gz

# calculate checksum
sha256sum v0.0.1.tar.gz

# update PKGBUILD: replace 'SKIP' with the checksum
# Then update AUR repo
```

### 4. Push to AUR
```bash
cd /path/to/sessionmanager-aur

# update PKGBUILD with real GitHub username and checksum
vim PKGBUILD

# generate .SRCINFO
makepkg --printsrcinfo > .SRCINFO

# commit and push
git add PKGBUILD .SRCINFO
git commit -m "initial release v0.0.1"
git push aur master
```

## 🎯 After Release

Users can install with:
```bash
yay -S sessionmanager
```

## 📝 User Data Location

User data remains in: `~/.local/share/sessionmanager/`
- activity.db
- whitelist.txt
- monitor.pid

This is NOT removed during cleanup - only manual installation files were removed.
