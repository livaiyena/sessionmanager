#!/bin/bash

# uninstallation script for sessionmanager
# removes manual installation from ~/.local

set -e

# colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # no color

# installation directories
INSTALL_PREFIX="$HOME/.local"
BIN_DIR="$INSTALL_PREFIX/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
DOC_DIR="$INSTALL_PREFIX/share/doc/sessionmanager"

# get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo -e "${BLUE}+----------------------------------------------------------╗${NC}"
echo -e "${BLUE}|    SessionManager - Uninstallation Script               |${NC}"
echo -e "${BLUE}+----------------------------------------------------------╝${NC}"
echo ""
echo -e "${YELLOW}This will remove SessionManager from ~/.local${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel, or Enter to continue...${NC}"
read

# stop service if running
echo -e "${BLUE}[1/5] Stopping service...${NC}"
if systemctl --user is-active --quiet sessionmanager 2>/dev/null; then
    systemctl --user stop sessionmanager && \
    echo -e "${GREEN}[+] Service stopped${NC}"
else
    echo -e "${BLUE}[+] Service not running${NC}"
fi

if systemctl --user is-enabled --quiet sessionmanager 2>/dev/null; then
    systemctl --user disable sessionmanager && \
    echo -e "${GREEN}[+] Service disabled${NC}"
fi
echo ""

# remove binary
echo -e "${BLUE}[2/5] Removing binary...${NC}"
if [ -f "$BIN_DIR/sessionmanager" ]; then
    rm -f "$BIN_DIR/sessionmanager" && \
    echo -e "${GREEN}[+] Binary removed${NC}"
else
    echo -e "${BLUE}[+] Binary not found${NC}"
fi
echo ""

# remove python package
echo -e "${BLUE}[3/5] Removing Python package...${NC}"
if python3 -m pip uninstall -y sessionmanager &> /dev/null; then
    echo -e "${GREEN}[+] Python package uninstalled${NC}"
else
    # fallback: manual removal
    SITE_PACKAGES=$(python3 -c "import site; print(site.USER_SITE)" 2>/dev/null)
    if [ -d "$SITE_PACKAGES/sessionmanager" ]; then
        rm -rf "$SITE_PACKAGES/sessionmanager" && \
        echo -e "${GREEN}[+] Python modules removed${NC}"
    else
        echo -e "${BLUE}[+] Python package not found${NC}"
    fi
fi
echo ""

# remove systemd service
echo -e "${BLUE}[4/5] Removing systemd service...${NC}"
if [ -f "$SYSTEMD_DIR/sessionmanager.service" ]; then
    rm -f "$SYSTEMD_DIR/sessionmanager.service" && \
    systemctl --user daemon-reload && \
    echo -e "${GREEN}[+] Service removed${NC}"
else
    echo -e "${BLUE}[+] Service not found${NC}"
fi
echo ""

# remove documentation
echo -e "${BLUE}[5/5] Removing documentation...${NC}"
if [ -d "$DOC_DIR" ]; then
    rm -rf "$DOC_DIR" && \
    echo -e "${GREEN}[+] Documentation removed${NC}"
else
    echo -e "${BLUE}[+] Documentation not found${NC}"
fi
echo ""

# clean up completion lines from shell configs
echo -e "${BLUE}Cleaning shell completions...${NC}"
COMPLETIONS_DIR="$SCRIPT_DIR/completions"

if [ -f "$HOME/.bashrc" ]; then
    sed -i "/# sessionmanager bash completion/d" "$HOME/.bashrc" 2>/dev/null || true
    sed -i "\|source $COMPLETIONS_DIR/sessionmanager.bash|d" "$HOME/.bashrc" 2>/dev/null || true
    echo -e "${GREEN}[+] Bash completion references removed${NC}"
fi

if [ -f "$HOME/.zshrc" ]; then
    sed -i "/# sessionmanager zsh completion/d" "$HOME/.zshrc" 2>/dev/null || true
    sed -i "\|fpath=($COMPLETIONS_DIR|d" "$HOME/.zshrc" 2>/dev/null || true
    echo -e "${GREEN}[+] Zsh completion references removed${NC}"
fi

if [ -f "$HOME/.config/fish/completions/sessionmanager.fish" ]; then
    rm -f "$HOME/.config/fish/completions/sessionmanager.fish" && \
    echo -e "${GREEN}[+] Fish completion removed${NC}"
fi

# remove data directory (optional)
echo ""
echo -e "${YELLOW}Data directory: ~/.local/share/sessionmanager${NC}"
echo -e "${YELLOW}This contains your activity database and settings.${NC}"
echo -e "${YELLOW}Remove it? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    rm -rf "$HOME/.local/share/sessionmanager" && \
    echo -e "${GREEN}[+] Data directory removed${NC}"
else
    echo -e "${BLUE}[+] Data directory preserved${NC}"
fi

echo ""
echo -e "${GREEN}+----------------------------------------------------------╗${NC}"
echo -e "${GREEN}|         Uninstallation Complete                          |${NC}"
echo -e "${GREEN}+----------------------------------------------------------╝${NC}"
echo ""
echo -e "${BLUE}Note: Reload your shell for completion changes to take effect${NC}"
echo ""
