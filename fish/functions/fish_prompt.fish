function fish_prompt
    set -l last_status $status

    # Colors
    set -l amber (set_color ffb040)
    set -l yellow (set_color ffd080)
    set -l orange (set_color e87820)
    set -l red (set_color ff5555)
    set -l green (set_color 50fa7b)
    set -l normal (set_color normal)

    # Current working directory
    set -l cwd_str (prompt_pwd)

    # Git branch info
    set -l git_info ""
    if command -sq git
        set -l branch (command git symbolic-ref --short HEAD 2>/dev/null; or command git rev-parse --short HEAD 2>/dev/null)
        if test -n "$branch"
            set -l git_dirty (command git status --porcelain 2>/dev/null)
            if test -n "$git_dirty"
                set git_info " $orange($branch*)$normal"
            else
                set git_info " $green($branch)$normal"
            end
        end
    end

    # Prompt symbol
    set -l symbol "$amber>$normal"
    if test $last_status -ne 0
        set symbol "$red>$normal"
    end

    # Print prompt
    echo -e ""
    echo -s "$yellow$cwd_str$normal$git_info"
    echo -n -s "$symbol "
end

