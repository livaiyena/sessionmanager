#!/bin/bash

# installation script for session manager with convenient aliases

# colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # no color

echo -e "${BLUE}session manager installation${NC}"

# get the absolute path to session_manager.py
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SESSION_MANAGER_PATH="$SCRIPT_DIR/session_manager.py"

# verify python script exists
if [ ! -f "$SESSION_MANAGER_PATH" ]; then
    echo "error: session_manager.py not found in $SCRIPT_DIR"
    exit 1
fi

# create data directory
mkdir -p ~/.local/share/sessionmanager
echo -e "${GREEN}created data directory${NC}"

# create shell aliases file
ALIASES_FILE="$HOME/.sessionmanager_aliases"
cat > "$ALIASES_FILE" << EOF
# session manager aliases
# convenient shortcuts for session manager commands

# main command shortcut
alias sm='python $SESSION_MANAGER_PATH'

# monitor commands
alias sm-start='python $SESSION_MANAGER_PATH monitor start'
alias sm-stop='python $SESSION_MANAGER_PATH monitor stop'
alias sm-status='python $SESSION_MANAGER_PATH monitor status'

# session commands
alias sm-session='python $SESSION_MANAGER_PATH session start'
alias sm-end='python $SESSION_MANAGER_PATH session stop'
alias sm-current='python $SESSION_MANAGER_PATH session current'

# report commands
alias sm-daily='python $SESSION_MANAGER_PATH report daily'
alias sm-weekly='python $SESSION_MANAGER_PATH report weekly'

# macro commands
alias sm-macros='python $SESSION_MANAGER_PATH macro list'
alias sm-macro-create='python $SESSION_MANAGER_PATH macro create'
alias sm-macro-run='python $SESSION_MANAGER_PATH macro run'
alias sm-macro-delete='python $SESSION_MANAGER_PATH macro delete'
EOF

echo -e "${GREEN}created aliases file at $ALIASES_FILE${NC}"

# add source line to bashrc if not already present
BASHRC="$HOME/.bashrc"
SOURCE_LINE="source $ALIASES_FILE"

if ! grep -qF "$SOURCE_LINE" "$BASHRC" 2>/dev/null; then
    echo "" >> "$BASHRC"
    echo "# session manager aliases" >> "$BASHRC"
    echo "$SOURCE_LINE" >> "$BASHRC"
    echo -e "${GREEN}added aliases to $BASHRC${NC}"
else
    echo -e "${BLUE}aliases already in $BASHRC${NC}"
fi

# install bash completions
if [ -f "$SCRIPT_DIR/completions/session_manager.bash" ]; then
    BASH_COMPLETION_LINE="source $SCRIPT_DIR/completions/session_manager.bash"
    if ! grep -qF "$BASH_COMPLETION_LINE" "$BASHRC" 2>/dev/null; then
        echo "" >> "$BASHRC"
        echo "# session manager bash completion" >> "$BASHRC"
        echo "$BASH_COMPLETION_LINE" >> "$BASHRC"
        echo -e "${GREEN}installed bash completions for tab completion${NC}"
    else
        echo -e "${BLUE}bash completions already installed${NC}"
    fi
fi

# add to zshrc if it exists
ZSHRC="$HOME/.zshrc"
if [ -f "$ZSHRC" ]; then
    if ! grep -qF "$SOURCE_LINE" "$ZSHRC" 2>/dev/null; then
        echo "" >> "$ZSHRC"
        echo "# session manager aliases" >> "$ZSHRC"
        echo "$SOURCE_LINE" >> "$ZSHRC"
        echo -e "${GREEN}added aliases to $ZSHRC${NC}"
    else
        echo -e "${BLUE}aliases already in $ZSHRC${NC}"
    fi
    
    # install zsh completions
    if [ -f "$SCRIPT_DIR/completions/_session_manager" ]; then
        # add fpath for custom completions
        ZSH_FPATH_LINE="fpath=($SCRIPT_DIR/completions \$fpath)"
        if ! grep -qF "$ZSH_FPATH_LINE" "$ZSHRC" 2>/dev/null; then
            echo "" >> "$ZSHRC"
            echo "# session manager zsh completion" >> "$ZSHRC"
            echo "$ZSH_FPATH_LINE" >> "$ZSHRC"
            echo "autoload -Uz compinit && compinit" >> "$ZSHRC"
            echo -e "${GREEN}installed zsh completions for tab completion${NC}"
        else
            echo -e "${BLUE}zsh completions already installed${NC}"
        fi
    fi
fi

# add to fish config if it exists
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [ -f "$FISH_CONFIG" ]; then
    # create fish aliases file
    FISH_ALIASES="$HOME/.config/fish/sessionmanager_aliases.fish"
    cat > "$FISH_ALIASES" << EOF
# session manager aliases for fish shell

# main command shortcut
alias sm='python $SESSION_MANAGER_PATH'

# monitor commands
alias sm-start='python $SESSION_MANAGER_PATH monitor start'
alias sm-stop='python $SESSION_MANAGER_PATH monitor stop'
alias sm-status='python $SESSION_MANAGER_PATH monitor status'

# session commands
alias sm-session='python $SESSION_MANAGER_PATH session start'
alias sm-end='python $SESSION_MANAGER_PATH session stop'
alias sm-current='python $SESSION_MANAGER_PATH session current'

# report commands
alias sm-daily='python $SESSION_MANAGER_PATH report daily'
alias sm-weekly='python $SESSION_MANAGER_PATH report weekly'

# macro commands
alias sm-macros='python $SESSION_MANAGER_PATH macro list'
alias sm-macro-create='python $SESSION_MANAGER_PATH macro create'
alias sm-macro-run='python $SESSION_MANAGER_PATH macro run'
alias sm-macro-delete='python $SESSION_MANAGER_PATH macro delete'
EOF

    FISH_SOURCE_LINE="source $FISH_ALIASES"
    if ! grep -qF "$FISH_SOURCE_LINE" "$FISH_CONFIG" 2>/dev/null; then
        echo "" >> "$FISH_CONFIG"
        echo "# session manager aliases" >> "$FISH_CONFIG"
        echo "$FISH_SOURCE_LINE" >> "$FISH_CONFIG"
        echo -e "${GREEN}added aliases to $FISH_CONFIG${NC}"
    else
        echo -e "${BLUE}aliases already in $FISH_CONFIG${NC}"
    fi
    
    # install fish completions
    FISH_COMPLETIONS_DIR="$HOME/.config/fish/completions"
    mkdir -p "$FISH_COMPLETIONS_DIR"
    if [ -f "$SCRIPT_DIR/completions/session_manager.py.fish" ]; then
        cp "$SCRIPT_DIR/completions/session_manager.py.fish" "$FISH_COMPLETIONS_DIR/"
        echo -e "${GREEN}installed fish completions for tab completion${NC}"
    fi
fi

echo ""
echo -e "${GREEN}installation complete${NC}"
echo ""
echo "available aliases:"
echo "  sm              - base command"
echo "  sm-start        - start monitoring daemon"
echo "  sm-stop         - stop monitoring daemon"
echo "  sm-status       - check daemon status"
echo "  sm-session      - start a work session"
echo "  sm-end          - end current session"
echo "  sm-current      - show current session"
echo "  sm-daily        - show daily report"
echo "  sm-weekly       - show weekly report"
echo "  sm-macros       - list all macros"
echo "  sm-macro-create - create new macro"
echo "  sm-macro-run    - run saved macro"
echo "  sm-macro-delete - delete macro"
echo ""
echo "reload your shell or run:"
echo "  bash/zsh: source ~/.bashrc (or ~/.zshrc)"
echo "  fish:     source ~/.config/fish/config.fish"
