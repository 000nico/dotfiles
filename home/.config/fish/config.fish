set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
set -gx TZ America/Argentina/Buenos_Aires

if status is-interactive
    set -g fish_greeting

    # Paleta generada por Noctalia (modo claro/oscuro).
    if test -f ~/.config/fish/noctalia-colors.fish
        source ~/.config/fish/noctalia-colors.fish
    end

    set -gx EDITOR nano
    set -gx VISUAL $EDITOR
    set -gx PAGER less

    alias ll 'ls -lah --color=auto'
    alias la 'ls -A --color=auto'
    alias c clear
    alias q exit

    # Prompt: starship
    if type -q starship
        starship init fish | source
    end

    if type -q fastfetch
        fastfetch --config /home/nico/.config/fastfetch/config.jsonc
        echo ""
	echo ""
    end
end


# Added by Antigravity CLI installer
set -gx PATH "/home/nico/.local/bin" $PATH
