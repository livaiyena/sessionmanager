#!/bin/bash

# installation script for sessionmanager shell completions
# for development or manual installation only
# aur users dont need this, completions are installed automatically

set -e

# colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # no color

echo -e "${BLUE}SessionManager - Shell Completion Installer${NC}"
echo ""

# get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
COMPLETIONS_DIR="$SCRIPT_DIR/completions"

# verify completions directory exists
if [ ! -d "$COMPLETIONS_DIR" ]; then
    echo -e "${YELLOW}Error: completions directory not found${NC}"
    exit 1
fi

echo -e "${YELLOW}Note: This script is for manual/development setup only.${NC}"
echo -e "${YELLOW}For production use, install via AUR (yay -S sessionmanager)${NC}"
echo ""

# bash completion
if [ -f "$COMPLETIONS_DIR/sessionmanager.bash" ]; then
    BASHRC="$HOME/.bashrc"
    BASH_COMPLETION_LINE="source $COMPLETIONS_DIR/sessionmanager.bash"
    
    if [ -f "$BASHRC" ]; then
        if ! grep -qF "$BASH_COMPLETION_LINE" "$BASHRC" 2>/dev/null; then
            echo "" >> "$BASHRC"
            echo "# sessionmanager bash completion" >> "$BASHRC"
            echo "$BASH_COMPLETION_LINE" >> "$BASHRC"
            echo -e "${GREEN}✓ Installed Bash completion${NC}"
        else
            echo -e "${BLUE}✓ Bash completion already installed${NC}"
        fi
    fi
fi

# zsh completion
if [ -f "$COMPLETIONS_DIR/_sessionmanager" ]; then
    ZSHRC="$HOME/.zshrc"
    
    if [ -f "$ZSHRC" ]; then
        ZSH_FPATH_LINE="fpath=($COMPLETIONS_DIR \$fpath)"
        
        if ! grep -qF "$ZSH_FPATH_LINE" "$ZSHRC" 2>/dev/null; then
            echo "" >> "$ZSHRC"
            echo "# sessionmanager zsh completion" >> "$ZSHRC"
            echo "$ZSH_FPATH_LINE" >> "$ZSHRC"
            echo "autoload -Uz compinit && compinit" >> "$ZSHRC"
            echo -e "${GREEN}✓ Installed Zsh completion${NC}"
        else
            echo -e "${BLUE}✓ Zsh completion already installed${NC}"
        fi
    fi
fi

# fish completion
if [ -f "$COMPLETIONS_DIR/sessionmanager.fish" ]; then
    FISH_COMPLETIONS_DIR="$HOME/.config/fish/completions"
    
    if [ -d "$HOME/.config/fish" ]; then
        mkdir -p "$FISH_COMPLETIONS_DIR"
        cp "$COMPLETIONS_DIR/sessionmanager.fish" "$FISH_COMPLETIONS_DIR/"
        echo -e "${GREEN}✓ Installed Fish completion${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Installation complete!${NC}"
echo ""
echo "Reload your shell or run:"
echo "  bash: source ~/.bashrc"
echo "  zsh:  source ~/.zshrc"
echo "  fish: (completions auto-load)"
echo ""
echo "Usage: sessionmanager <TAB> for completions"
