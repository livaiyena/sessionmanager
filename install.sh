#!/bin/bash
# sessionmanager installer (local)

set -e

INSTALL_PREFIX="$HOME/.local"
BIN_DIR="$INSTALL_PREFIX/bin"
SYSTEMD_DIR="$HOME/.config/systemd/user"
DOC_DIR="$INSTALL_PREFIX/share/doc/sessionmanager"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

echo "installing sessionmanager to ~/.local"

# 1. check requirements
if ! command -v python3 &> /dev/null; then
    echo "error: python 3 required"
    exit 1
fi

if ! command -v hyprctl &> /dev/null; then
    echo "warning: hyprland not found (required for functionality)"
fi

# 2. create dirs
mkdir -p "$BIN_DIR" "$SYSTEMD_DIR" "$DOC_DIR"

# 3. install python pkg
cd "$SCRIPT_DIR"
if python3 -m pip install --user -e . &> /dev/null; then
    echo "python package installed"
else
    # fallback
    SITE_PACKAGES=$(python3 -c "import site; print(site.USER_SITE)")
    mkdir -p "$SITE_PACKAGES"
    cp -r "$SCRIPT_DIR/src/sessionmanager" "$SITE_PACKAGES/" || { echo "error: failed to install python pkg"; exit 1; }
    echo "python modules copied"
fi

# 4. install binary
cp "$SCRIPT_DIR/sessionmanager" "$BIN_DIR/sessionmanager"
chmod +x "$BIN_DIR/sessionmanager"
echo "binary installed"

# path check
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo "note: add $HOME/.local/bin to PATH"
fi

# 5. install service
sed "s|/usr/bin/sessionmanager|$BIN_DIR/sessionmanager|g" "$SCRIPT_DIR/sessionmanager.service" > "$SYSTEMD_DIR/sessionmanager.service"
echo "service installed"

# 6. install completions
COMPLETIONS_DIR="$SCRIPT_DIR/completions"

# bash
if [ -f "$COMPLETIONS_DIR/sessionmanager.bash" ] && [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "sessionmanager.bash" "$HOME/.bashrc"; then
        echo "source $COMPLETIONS_DIR/sessionmanager.bash" >> "$HOME/.bashrc"
        echo "bash completion added"
    fi
fi

# zsh
if [ -f "$COMPLETIONS_DIR/_sessionmanager" ] && [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "$COMPLETIONS_DIR" "$HOME/.zshrc"; then
        echo "fpath=($COMPLETIONS_DIR \$fpath)" >> "$HOME/.zshrc"
        echo "autoload -Uz compinit && compinit" >> "$HOME/.zshrc"
        echo "zsh completion added"
    fi
fi

# fish
if [ -f "$COMPLETIONS_DIR/sessionmanager.fish" ] && [ -d "$HOME/.config/fish" ]; then
    mkdir -p "$HOME/.config/fish/completions"
    cp "$COMPLETIONS_DIR/sessionmanager.fish" "$HOME/.config/fish/completions/"
    echo "fish completion installed"
fi

# 7. docs
cp "$SCRIPT_DIR/README.md" "$DOC_DIR/"
cp "$SCRIPT_DIR/CHANGELOG.md" "$DOC_DIR/" 2>/dev/null || true

echo "done. reload shell and start service."
