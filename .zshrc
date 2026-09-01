# ──────────────────────────────────────────────────────────────
# Powerlevel10k — instant prompt disabled (fastfetch runs first)
# ──────────────────────────────────────────────────────────────
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# ──────────────────────────────────────────────────────────────
# PATH & Environment
# ──────────────────────────────────────────────────────────────
export PATH="/run/wrappers/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="bat --paging=always"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"
export BAT_THEME="base16"

# ──────────────────────────────────────────────────────────────
# History
# ──────────────────────────────────────────────────────────────
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# ──────────────────────────────────────────────────────────────
# Shell Options
# ──────────────────────────────────────────────────────────────
setopt AUTO_CD
setopt GLOB_DOTS
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS

# ──────────────────────────────────────────────────────────────
# Completion
# ──────────────────────────────────────────────────────────────
autoload -Uz compinit
compinit -d "$HOME/.cache/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:warnings' format '%F{red}No matches: %d%f'
zstyle ':completion:*' squeeze-slashes true

# ──────────────────────────────────────────────────────────────
# Powerlevel10k Theme
# ──────────────────────────────────────────────────────────────
_p10k_theme=""
[[ -f "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]] &&
    _p10k_theme="$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
[[ -z "$_p10k_theme" && -f "/run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]] &&
    _p10k_theme="/run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
[[ -n "$_p10k_theme" ]] && source "$_p10k_theme"
unset _p10k_theme

[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh

# ──────────────────────────────────────────────────────────────
# Zsh Plugins
# ──────────────────────────────────────────────────────────────
_load_plugin() {
    local file="$1"
    [[ -f "$HOME/.nix-profile/share/$file" ]] && source "$HOME/.nix-profile/share/$file" && return
    [[ -f "/run/current-system/sw/share/$file" ]] && source "/run/current-system/sw/share/$file"
}

_load_plugin "zsh-autosuggestions/zsh-autosuggestions.zsh"
_load_plugin "zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
unset -f _load_plugin

# Tune autosuggestion style
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#6b4fa0,underline"
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ──────────────────────────────────────────────────────────────
# Key Bindings
# ──────────────────────────────────────────────────────────────
bindkey -e
bindkey '^[[A'  up-line-or-search
bindkey '^[[B'  down-line-or-search
bindkey '^[[H'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[[3~' delete-char
bindkey '^[[1;5C' forward-word    # Ctrl+Right
bindkey '^[[1;5D' backward-word   # Ctrl+Left
bindkey '^U'    backward-kill-line
bindkey '^K'    kill-line
bindkey '^[[Z'  reverse-menu-complete  # Shift+Tab

# ──────────────────────────────────────────────────────────────
# Aliases — Navigation
# ──────────────────────────────────────────────────────────────
alias ls="eza --icons --group-directories-first --colour=always"
alias la="eza -a --icons --group-directories-first --colour=always"
alias ll="eza -la --icons --group-directories-first --git --colour=always"
alias lt="eza --tree --icons --level=2"
alias lta="eza --tree --icons --level=2 -a"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ──────────────────────────────────────────────────────────────
# Aliases — Tools
# ──────────────────────────────────────────────────────────────
alias cat="bat --paging=never"
alias grep="grep --color=auto"
alias diff="diff --color=auto"
alias ff="fastfetch"
alias top="btop"
alias y="yazi"
alias g="git"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate -15"

# ──────────────────────────────────────────────────────────────
# Aliases — NixOS
# ──────────────────────────────────────────────────────────────
alias nrs="sudo nixos-rebuild switch"
alias nrt="sudo nixos-rebuild test"
alias nrb="sudo nixos-rebuild boot"
alias nse="sudo nano /etc/nixos/configuration.nix"
alias nve="nvim /etc/nixos/configuration.nix"
alias ngc="sudo nix-collect-garbage -d"
alias nup="sudo nix-channel --update && sudo nixos-rebuild switch"

# ──────────────────────────────────────────────────────────────
# Aliases — System
# ──────────────────────────────────────────────────────────────
alias reload="source ~/.zshrc"
alias zshrc="nvim ~/.zshrc"
alias q="exit"
alias c="clear"
alias mkdir="mkdir -pv"
alias cp="cp -iv"
alias mv="mv -iv"
alias rm="rm -iv"
alias df="df -h"
alias free="free -h"
alias ports="ss -tulpn"
alias myip="curl -s ifconfig.me"

# ──────────────────────────────────────────────────────────────
# Functions
# ──────────────────────────────────────────────────────────────

# Neovim — zero-padding mode in kitty
nvim() {
    kitty @ set-spacing padding=0 2>/dev/null
    command nvim "$@"
    kitty @ set-spacing padding=default 2>/dev/null
}
alias v="nvim"

# mkcd — create dir and cd into it
mkcd() { mkdir -p "$1" && cd "$1"; }

# extract — universal archive extractor
extract() {
    case "$1" in
        *.tar.gz|*.tgz)  tar xzf "$1" ;;
        *.tar.bz2)       tar xjf "$1" ;;
        *.tar.xz)        tar xJf "$1" ;;
        *.tar)           tar xf  "$1" ;;
        *.zip)           unzip   "$1" ;;
        *.gz)            gunzip  "$1" ;;
        *.rar)           unrar x "$1" ;;
        *.7z)            7z x    "$1" ;;
        *)               echo "extract: unknown format '$1'" ;;
    esac
}

# nix-shell shorthand — drop into a shell with packages
ns() { nix-shell --extra-experimental-features 'nix-command flakes' -p "$@"; }

# nix search shorthand
nix-search() { nix search nixpkgs "$@" --extra-experimental-features 'nix-command flakes'; }

# yazi — cd on quit
yy() {
    local tmp cwd
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
    yazi "$@" --cwd-file="$tmp"
    cwd="$(cat -- "$tmp")" 2>/dev/null
    [[ -n "$cwd" && "$cwd" != "$PWD" ]] && cd -- "$cwd"
    rm -f -- "$tmp"
}

# ──────────────────────────────────────────────────────────────
# Zoxide (smart cd — replaces cd with z)
# ──────────────────────────────────────────────────────────────
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh --cmd z)"
    alias cd="z"
fi

# ──────────────────────────────────────────────────────────────
# fzf integration
# ──────────────────────────────────────────────────────────────
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS="
        --height=50%
        --layout=reverse
        --border=rounded
        --info=inline
        --color=fg:#e9d5ff,fg+:#c084fc,bg:#080512,bg+:#0f0a1e
        --color=hl:#a855f7,hl+:#d8b4fe,border:#c084fc,prompt:#c084fc
        --color=pointer:#c084fc,marker:#7c3aed,spinner:#a855f7,header:#b8a0d8
        --prompt='  '
        --pointer='❯'
        --marker='●'
    "
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git --exclude result'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

    # Ctrl+R — fuzzy history
    bindkey '^R' fzf-history-widget
    # Ctrl+T — fuzzy file picker
    bindkey '^T' fzf-file-widget
    # Alt+C — fuzzy cd
    bindkey '^[c' fzf-cd-widget

    autoload -Uz fzf
    source <(fzf --zsh 2>/dev/null) || true
fi

# ──────────────────────────────────────────────────────────────
# Run fastfetch on interactive login
# ──────────────────────────────────────────────────────────────
if [[ -o interactive ]]; then
    fastfetch
fi
