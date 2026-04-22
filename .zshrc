# =============================================================================
# Powerlevel10k instant prompt — MUST stay near the top of ~/.zshrc.
# Initialization that may require console input (passwords, [y/n] prompts) must
# go ABOVE this block; everything else may go below.
# =============================================================================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# =============================================================================
# PATH (consolidated)
# =============================================================================
# Cross-platform PNPM_HOME
if [[ "$OSTYPE" == darwin* ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi

typeset -U path  # dedupe PATH entries automatically
path=(
    "$HOME/.local/bin"
    "$HOME/bin"
    "$HOME/cli-tools"
    "$HOME/.docker/bin"
    "$PNPM_HOME"
    "$HOME/.opencode/bin"
    $path
)

# macOS-specific PATH entries
if [[ "$OSTYPE" == darwin* ]]; then
    path=(
        "$HOME/nvim-macos/bin"
        "/opt/homebrew/opt/libpq@18/bin"
        $path
    )
fi


# =============================================================================
# zinit (self-bootstrapping plugin manager)
# =============================================================================
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# Plugins — heavy ones deferred until after the prompt is painted (wait'0a')
zinit ice wait'0a' lucid
zinit light zsh-users/zsh-autosuggestions

zinit ice wait'0b' lucid atinit'zicompinit; zicdreplay'
zinit light zsh-users/zsh-syntax-highlighting

# Completions for kubectl/npm — lazy, only initialized when first invoked
zinit ice wait'1' lucid as'completion' \
    atload'(( $+commands[kubectl] )) && source <(kubectl completion zsh)'
zinit light zsh-users/zsh-completions


# =============================================================================
# Powerlevel10k theme
# =============================================================================
source ~/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/repos/dotfiles/.p10k.zsh ]] || source ~/repos/dotfiles/.p10k.zsh


# =============================================================================
# mise — manages Node, Python, etc. Reads .nvmrc, .python-version, .tool-versions
# =============================================================================
if (( $+commands[mise] )); then
    eval "$(mise activate zsh)"
fi


# =============================================================================
# cd hook — auto-activate Python virtualenv when entering a directory.
# Node version switching is handled natively by mise (no nvm use needed).
# =============================================================================
function cd() {
    builtin cd "$@" || return
    if [[ -d ./.venv ]]; then
        . ./.venv/bin/activate
    fi
}
# Activate venv for the current directory at shell startup (no `cd .` needed)
[[ -d ./.venv ]] && . ./.venv/bin/activate


# =============================================================================
# Per-device scripts (kept out of dotfiles repo intentionally)
# =============================================================================
if [[ -d ~/zshrc ]]; then
    # Ensure compinit is loaded so scripts using compdef (e.g. completion files) work
    autoload -Uz compinit && compinit -C
    for FILE in ~/zshrc/*; do
        source "$FILE"
    done
fi


# =============================================================================
# Aliases & env
# =============================================================================
alias ls="ls -la"
alias rc="nvim ~/.zshrc"
alias n="nvim ."
alias nconf="cd ~/.config/nvim && nvim ."
alias py="python3"
alias pip="python3 -m pip"

export EDITOR="nvim"
export MYVIMRC="~/.config/nvim"

# Vi mode on the command line
set -o vi


# =============================================================================
# fzf helpers
# =============================================================================
search_repos() {
    command find ~/repos \( -name 'node_modules' -o -name '.git' -o -name '__pycache__' -o -name '.venv' \) -prune -o -print \
        | fzf --preview 'cat {}' \
        | xargs -S1024 -I % nvim %
}
search_repos_and_session() {
    command find ~/repos -maxdepth 2 \( -name 'node_modules' -o -name '.git' \) -prune -o -type d -print \
        | fzf \
        | xargs -S1024 -I{} sh -c 'tmux new -Ads {} -c {} && echo "opening as session {}" && tmux switch -t {}'
}
zle -N search_repos
zle -N search_repos_and_session
bindkey "^F" search_repos
bindkey "^P" search_repos_and_session


# =============================================================================
# Helpers
# =============================================================================
function decode_jwt() {
    if [[ -z "$1" ]]; then
        echo "Usage: decode_jwt <token>"
        return 1
    fi

    local token="$1"
    local header=$(echo "$token" | cut -d '.' -f1 | base64 --decode)
    local payload=$(echo "$token" | cut -d '.' -f2 | base64 --decode)

    echo "Header:"
    echo "$header"
    echo ""
    echo "Payload:"
    echo "$payload"
}


# =============================================================================
# Cargo / Rust env (from rustup installer)
# =============================================================================
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
