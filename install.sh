#!/bin/bash

# full installation script for sessionmanager
# for manual/local installation - installs to ~/.local
# for production use, install via aur (yay -S sessionmanager)

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
echo -e "${BLUE}|     SessionManager - Manual Installation Script         |${NC}"
echo -e "${BLUE}+----------------------------------------------------------╝${NC}"
echo ""
echo -e "${YELLOW}Note: This installs to ~/.local for user-level access${NC}"
echo -e "${YELLOW}For system-wide installation, use AUR: yay -S sessionmanager${NC}"
echo ""

# check python version
echo -e "${BLUE}[1/6] Checking requirements...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}[x] Python 3 not found${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(f"{sys.version_info.major}.{sys.version_info.minor}")')
echo -e "${GREEN}[+] Python $PYTHON_VERSION found${NC}"

# check hyprland
if ! command -v hyprctl &> /dev/null; then
    echo -e "${YELLOW}[!] Hyprland not detected - sessionmanager requires Hyprland${NC}"
    echo -e "${YELLOW}  Continuing anyway (install Hyprland before use)${NC}"
else
    echo -e "${GREEN}[+] Hyprland detected${NC}"
fi

echo ""

# create directories
echo -e "${BLUE}[2/6] Creating installation directories...${NC}"
mkdir -p "$BIN_DIR" || { echo -e "${RED}✗ Failed to create $BIN_DIR${NC}"; exit 1; }
mkdir -p "$SYSTEMD_DIR" || { echo -e "${RED}✗ Failed to create $SYSTEMD_DIR${NC}"; exit 1; }
mkdir -p "$DOC_DIR" || { echo -e "${RED}✗ Failed to create $DOC_DIR${NC}"; exit 1; }
echo -e "${GREEN}[+] Directories created${NC}"
echo ""

# install python package
echo -e "${BLUE}[3/6] Installing Python package...${NC}"
cd "$SCRIPT_DIR"

# use pip to install in editable mode for easy development
if python3 -m pip install --user -e . &> /dev/null; then
    echo -e "${GREEN}[+] Python package installed (editable mode)${NC}"
else
    echo -e "${YELLOW}[!] pip install failed, trying manual copy...${NC}"
    
    # fallback: manual copy to site-packages
    SITE_PACKAGES=$(python3 -c "import site; print(site.USER_SITE)")
    mkdir -p "$SITE_PACKAGES"
    
    if cp -r "$SCRIPT_DIR/src/sessionmanager" "$SITE_PACKAGES/"; then
        echo -e "${GREEN}[+] Python modules copied to $SITE_PACKAGES${NC}"
    else
        echo -e "${RED}[x] Failed to install Python package${NC}"
        exit 1
    fi
fi
echo ""

# install main binary
echo -e "${BLUE}[4/6] Installing SessionManager binary...${NC}"
if cp "$SCRIPT_DIR/sessionmanager" "$BIN_DIR/sessionmanager" && \
   chmod +x "$BIN_DIR/sessionmanager"; then
    echo -e "${GREEN}[+] Binary installed to $BIN_DIR/sessionmanager${NC}"
else
    echo -e "${RED}[x] Failed to install binary${NC}"
    exit 1
fi

# check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}[!] Warning: $HOME/.local/bin is not in your PATH${NC}"
    echo -e "${YELLOW}  Add this line to your ~/.bashrc or ~/.zshrc:${NC}"
    echo -e "${YELLOW}  export PATH=\"\$HOME/.local/bin:\$PATH\"${NC}"
fi
echo ""

# install systemd service
echo -e "${BLUE}[5/6] Installing systemd service...${NC}"
if sed "s|/usr/bin/sessionmanager|$BIN_DIR/sessionmanager|g" \
   "$SCRIPT_DIR/sessionmanager.service" > "$SYSTEMD_DIR/sessionmanager.service"; then
    echo -e "${GREEN}[+] Service installed to $SYSTEMD_DIR/sessionmanager.service${NC}"
    echo -e "${BLUE}  Enable with: systemctl --user enable sessionmanager${NC}"
    echo -e "${BLUE}  Start with: systemctl --user start sessionmanager${NC}"
else
    echo -e "${YELLOW}[!] Failed to install systemd service${NC}"
fi
echo ""

# install shell completions
echo -e "${BLUE}[6/6] Installing shell completions...${NC}"
COMPLETIONS_DIR="$SCRIPT_DIR/completions"

# bash completion
if [ -f "$COMPLETIONS_DIR/sessionmanager.bash" ]; then
    BASHRC="$HOME/.bashrc"
    BASH_COMPLETION_LINE="source $COMPLETIONS_DIR/sessionmanager.bash"
    
    if [ -f "$BASHRC" ]; then
        if ! grep -qF "$BASH_COMPLETION_LINE" "$BASHRC" 2>/dev/null; then
            if echo "" >> "$BASHRC" 2>/dev/null && \
               echo "# sessionmanager bash completion" >> "$BASHRC" && \
               echo "$BASH_COMPLETION_LINE" >> "$BASHRC"; then
                echo -e "${GREEN}[+] Bash completion installed${NC}"
            else
                echo -e "${YELLOW}[!] Failed to install Bash completion${NC}"
            fi
        else
            echo -e "${BLUE}[+] Bash completion already installed${NC}"
        fi
    fi
fi

# zsh completion
if [ -f "$COMPLETIONS_DIR/_sessionmanager" ]; then
    ZSHRC="$HOME/.zshrc"
    
    if [ -f "$ZSHRC" ]; then
        ZSH_FPATH_LINE="fpath=($COMPLETIONS_DIR \$fpath)"
        
        if ! grep -qF "$ZSH_FPATH_LINE" "$ZSHRC" 2>/dev/null; then
            if echo "" >> "$ZSHRC" 2>/dev/null && \
               echo "# sessionmanager zsh completion" >> "$ZSHRC" && \
               echo "$ZSH_FPATH_LINE" >> "$ZSHRC" && \
               echo "autoload -Uz compinit && compinit" >> "$ZSHRC"; then
                echo -e "${GREEN}[+] Zsh completion installed${NC}"
            else
                echo -e "${YELLOW}[!] Failed to install Zsh completion${NC}"
            fi
        else
            echo -e "${BLUE}[+] Zsh completion already installed${NC}"
        fi
    fi
fi

# fish completion
if [ -f "$COMPLETIONS_DIR/sessionmanager.fish" ]; then
    FISH_COMPLETIONS_DIR="$HOME/.config/fish/completions"
    
    if [ -d "$HOME/.config/fish" ]; then
        if mkdir -p "$FISH_COMPLETIONS_DIR" 2>/dev/null && \
           cp "$COMPLETIONS_DIR/sessionmanager.fish" "$FISH_COMPLETIONS_DIR/" 2>/dev/null; then
            echo -e "${GREEN}[+] Fish completion installed${NC}"
        else
            echo -e "${YELLOW}[!] Failed to install Fish completion${NC}"
        fi
    fi
fi

# install documentation
if cp "$SCRIPT_DIR/README.md" "$DOC_DIR/" 2>/dev/null && \
   cp "$SCRIPT_DIR/CHANGELOG.md" "$DOC_DIR/" 2>/dev/null; then
    echo -e "${GREEN}[+] Documentation installed to $DOC_DIR${NC}"
fi

echo ""
echo -e "${GREEN}+----------------------------------------------------------╗${NC}"
echo -e "${GREEN}|            Installation Complete                         |${NC}"
echo -e "${GREEN}+----------------------------------------------------------╝${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Reload your shell: source ~/.bashrc (or ~/.zshrc)"
echo "  2. Start the daemon: sessionmanager monitor start"
echo "  3. Or use systemd: systemctl --user start sessionmanager"
echo ""
echo -e "${BLUE}Usage:${NC}"
echo "  sessionmanager --help"
echo "  sessionmanager session start --topic 'Work' --description 'Coding' --duration 90"
echo "  sessionmanager report daily"
echo ""
echo -e "${YELLOW}Uninstall:${NC}"
echo "  Run: $SCRIPT_DIR/uninstall.sh"
echo ""
