# Disable Powerlevel10k instant prompt to allow console output (fastfetch) cleanly
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off


source /usr/share/cachyos-zsh-config/cachyos-config.zsh


# Added by Antigravity CLI installer
export PATH="/home/nico/.local/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Run fastfetch on interactive shell startup
if [[ -o interactive ]]; then
  fastfetch
fi

