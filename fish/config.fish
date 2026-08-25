source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Added by Antigravity CLI installer
set -gx PATH "/home/nico/.local/bin" $PATH
set -gx TERMINAL kitty
alias nvim="kitty @ set-spacing padding=0; command nvim; kitty @ set-spacing padding=default"
