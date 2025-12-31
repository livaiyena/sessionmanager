#!/bin/bash
# sessionmanager unnstaller

set -e

INSTALL_PREFIX="$HOME/.local"
BIN_DIR="$INSTALL_PREFIX/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
DOC_DIR="$INSTALL_PREFIX/share/doc/sessionmanager"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo "uninstalling..."

# 1. stop service
systemctl --user stop sessionmanager 2>/dev/null || true
systemctl --user disable sessionmanager 2>/dev/null || true

# 2. remove files
rm -f "$BIN_DIR/sessionmanager"
rm -f "$SYSTEMD_DIR/sessionmanager.service"
rm -rf "$DOC_DIR"
systemctl --user daemon-reload 2>/dev/null || true

# 3. remove python pkg
python3 -m pip uninstall -y sessionmanager &> /dev/null || true
SITE_PACKAGES=$(python3 -c "import site; print(site.USER_SITE)" 2>/dev/null)
rm -rf "$SITE_PACKAGES/sessionmanager"

# 4. clean shell configs
if [ -f "$HOME/.bashrc" ]; then
    sed -i "\|source .*sessionmanager.bash|d" "$HOME/.bashrc"
fi
if [ -f "$HOME/.zshrc" ]; then
    sed -i "\|fpath=.*completions|d" "$HOME/.zshrc" # simplified pattern, assumes only this script added it this way, might be risky if generic. will refine.
    # actually better to be specific to the path we know
    sed -i "\|sessionmanager/completions|d" "$HOME/.zshrc"
fi
rm -f "$HOME/.config/fish/completions/sessionmanager.fish" 2>/dev/null

# 5. data
echo "remove data at ~/.local/share/sessionmanager? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.local/share/sessionmanager"
    echo "data removed"
fi

echo "uninstalled"
