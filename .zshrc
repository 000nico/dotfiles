# Disable Powerlevel10k instant prompt to allow console output (fastfetch) cleanly
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# Environment & PATH (preserve /run/wrappers/bin for setuid binaries like sudo)
export PATH="/run/wrappers/bin:$HOME/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

# History configuration
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS

# Basic shell options & completion
autoload -Uz compinit
compinit -d "$HOME/.cache/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Powerlevel10k Theme
if [[ -f "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source "$HOME/.nix-profile/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f "/run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme" ]]; then
    source "/run/current-system/sw/share/zsh-powerlevel10k/powerlevel10k.zsh-theme"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Zsh Plugins (Autosuggestions & Syntax Highlighting)
if [[ -f "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOME/.nix-profile/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -f "/run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "/run/current-system/sw/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi

if [[ -f "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOME/.nix-profile/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -f "/run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "/run/current-system/sw/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Key bindings
bindkey -e
bindkey '^[[A' up-line-or-search
bindkey '^[[B' down-line-or-search
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[3~' delete-char

# Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias tree="eza --tree --icons"
alias cat="bat --paging=never"
alias ff="fastfetch"
alias top="btop"
alias y="yazi"

# Neovim wrapper
nvim() {
    kitty @ set-spacing padding=0 2>/dev/null
    command nvim "$@"
    kitty @ set-spacing padding=default 2>/dev/null
}
alias v="nvim"

# Run fastfetch on interactive shell startup
if [[ -o interactive ]]; then
    fastfetch
fi
