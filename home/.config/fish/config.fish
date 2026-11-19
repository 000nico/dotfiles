set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
set -gx TZ America/Argentina/Buenos_Aires

if status is-interactive
    set -g fish_greeting
    set -g fish_color_command a8c8ff
    set -g fish_color_param e2e2e9
    set -g fish_color_keyword dcbce1
    set -g fish_color_error ffb4ab
    set -g fish_color_comment 8e9099
    set -g fish_color_quote dcbce1
    set -g fish_color_operator bdc7dc

    set -gx EDITOR nano
    set -gx VISUAL $EDITOR
    set -gx PAGER less

    alias ll 'ls -lah --color=auto'
    alias la 'ls -A --color=auto'
    alias c clear
    alias q exit

    function fish_prompt
        set -l code $status
        set -l symbol '>'
        if test $code -ne 0
            set symbol 'x'
        end
        set_color 8e9099
        printf '%s ' (prompt_pwd)
        set_color a8c8ff
        printf '%s ' $symbol
        set_color normal
    end

    if type -q fastfetch
        fastfetch --config /home/nico/.config/fastfetch/config.jsonc
        echo ""
	echo ""
    end
end


# Added by Antigravity CLI installer
set -gx PATH "/home/nico/.local/bin" $PATH
