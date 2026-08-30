source /usr/share/cachyos-fish-config/cachyos-config.fish

# Environment variables
set -gx PATH "/home/nico/.local/bin" $PATH
set -gx TERMINAL kitty
set -gx EDITOR nvim
set -gx VISUAL nvim

# Modern CLI Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias tree="eza --tree --icons"
alias cat="bat --paging=never"
alias ff="fastfetch"
alias top="btop"
alias y="yazi"
alias v="nvim"


# Greeting
function fish_greeting
    if status is-interactive
        fastfetch
    end
end

