# Disable Powerlevel10k instant prompt to allow console output (fastfetch) cleanly
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off


source /usr/share/cachyos-zsh-config/cachyos-config.zsh


# Added by Antigravity CLI installer
export PATH="/home/nico/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

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


