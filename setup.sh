#!/usr/bin/env bash
# Bootstrap script for dotfiles. Written in bash because zsh may not be
# installed yet — bash is universally available.
set -euo pipefail

REPO_EXPECTED_PATH="$HOME/repos/dotfiles"
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

echo "This will delete and replace your existing dotfiles (~/.zshrc, ~/.tmux.conf, ~/.p10k.zsh, ~/.config/nvim)."
echo -n "Type 'y' to continue, anything else to abort: "
read -r answer
if [[ "$answer" != "y" ]]; then
    echo "Aborting."
    exit 0
fi

if [[ "$SCRIPT_DIR" != "$REPO_EXPECTED_PATH" ]]; then
    echo ""
    echo "WARNING: This repo is at '$SCRIPT_DIR' but .zshrc expects it at '$REPO_EXPECTED_PATH'."
    echo "Some references (e.g. .p10k.zsh source path) will silently fail."
    echo -n "Continue anyway? (y/N): "
    read -r cont
    [[ "$cont" == "y" ]] || exit 1
fi

echo ""
echo "Installing dependencies..."

# -----------------------------------------------------------------------------
# 1. Homebrew (macOS only, if missing)
# -----------------------------------------------------------------------------
if [[ "$OSTYPE" == darwin* ]] && ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Ensure brew is on PATH for the rest of this script
    if [[ -x /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -x /usr/local/bin/brew ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# -----------------------------------------------------------------------------
# 2. zsh (install if missing) + set as default shell
# -----------------------------------------------------------------------------
if ! command -v zsh >/dev/null 2>&1; then
    echo "Installing zsh..."
    if [[ "$OSTYPE" == darwin* ]]; then
        brew install zsh
    elif [[ "$OSTYPE" == linux* ]]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    else
        echo "Unsupported OS for automatic zsh install: $OSTYPE" >&2
        exit 1
    fi
fi

# Set zsh as default shell. Prefer system zsh on macOS (already in /etc/shells).
ZSH_BIN="$(command -v zsh)"
if [[ "$OSTYPE" == darwin* && -x /bin/zsh ]]; then
    ZSH_BIN="/bin/zsh"
fi
if [[ "$SHELL" != "$ZSH_BIN" ]]; then
    # Ensure $ZSH_BIN is registered in /etc/shells
    if ! grep -qx "$ZSH_BIN" /etc/shells 2>/dev/null; then
        echo "Registering $ZSH_BIN in /etc/shells (requires sudo)..."
        echo "$ZSH_BIN" | sudo tee -a /etc/shells >/dev/null
    fi
    echo "Setting default shell to $ZSH_BIN..."
    chsh -s "$ZSH_BIN" || echo "WARNING: chsh failed — set your default shell manually."
fi

# -----------------------------------------------------------------------------
# 3. mise — universal version manager (replaces nvm + pyenv).
# -----------------------------------------------------------------------------
if ! command -v mise >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/mise" ]]; then
    echo "Installing mise..."
    curl https://mise.run | sh
fi
if [[ ! -x "$HOME/.local/bin/mise" ]]; then
    echo "ERROR: mise install failed — expected binary at ~/.local/bin/mise" >&2
    exit 1
fi
"$HOME/.local/bin/mise" use --global node@lts python@latest || true

# -----------------------------------------------------------------------------
# 4. Powerlevel10k theme (cross-platform)
# -----------------------------------------------------------------------------
if [[ ! -d "$HOME/powerlevel10k" ]]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/powerlevel10k"
fi

# zinit self-bootstraps from .zshrc on first shell start — no install needed here.

# -----------------------------------------------------------------------------
# 5. Platform-specific dependencies
# -----------------------------------------------------------------------------
if [[ "$OSTYPE" == darwin* ]]; then
    brew install tmux ripgrep fzf
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi
elif [[ "$OSTYPE" == linux* ]]; then
    sudo apt-get update
    sudo apt-get install -y \
        tmux \
        ripgrep \
        fzf \
        git \
        curl \
        ninja-build gettext cmake unzip build-essential

    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    fi

    # Build and install latest neovim from source into ~/.local
    if [[ ! -x "$HOME/.local/bin/nvim" ]]; then
        echo "Building neovim from source..."
        if [[ ! -d "$HOME/neovim" ]]; then
            git clone https://github.com/neovim/neovim.git "$HOME/neovim"
        fi
        (
            cd "$HOME/neovim"
            git checkout stable
            make CMAKE_BUILD_TYPE=Release CMAKE_INSTALL_PREFIX="$HOME/.local"
            make install
        )
    fi
fi

# -----------------------------------------------------------------------------
# 6. Symlinks
# -----------------------------------------------------------------------------
echo "Using script dir: $SCRIPT_DIR"
echo "Using home dir:   $HOME"

link() {
    local src="$1" dest="$2"
    if [[ -e "$dest" || -L "$dest" ]]; then
        rm -rf "$dest"
        echo "Removed existing $dest"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
}

link "$SCRIPT_DIR/nvim"        "$HOME/.config/nvim"
link "$SCRIPT_DIR/.zshrc"      "$HOME/.zshrc"
link "$SCRIPT_DIR/.tmux.conf"  "$HOME/.tmux.conf"
link "$SCRIPT_DIR/.p10k.zsh"   "$HOME/.p10k.zsh"
link "$SCRIPT_DIR/ghostty"     "$HOME/.config/ghostty"

echo ""
echo "Done. Open a new terminal (zsh) to apply changes."
echo "First shell startup will be slower (~3-5s) while zinit clones plugins; subsequent shells will be fast."
