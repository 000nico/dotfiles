# ~/.config/fish/conf.d/20-rice.fish
# Prompt + abbrs con la misma paleta que rofi / waybar / yazi:
# fondo #18181b · texto #d0d0d0 · acento arena #c9b890 · error #e06c75

set -g __rice_fg     '#d0d0d0'
set -g __rice_dim    '#8a8a8a'
set -g __rice_accent '#c9b890'
set -g __rice_bad    '#e06c75'
set -g __rice_good   '#98c379'
set -g __rice_warn   '#e5c07b'

# --- prompt de git (nativo de fish 4) ---
set -g __fish_git_prompt_char_branch         ''
set -g __fish_git_prompt_char_commit          ''
set -g __fish_git_prompt_char_dirty           '✚'
set -g __fish_git_prompt_char_staged          '●'
set -g __fish_git_prompt_char_untracked       '?'
set -g __fish_git_prompt_char_stashstate      '⚑'
set -g __fish_git_prompt_char_upstream_ahead  '↑'
set -g __fish_git_prompt_char_upstream_behind '↓'
set -g __fish_git_prompt_char_stateseparator  ' '
set -g __fish_git_prompt_char_cleanstate      ''
set -g __fish_git_prompt_color_prefix         ''
set -g __fish_git_prompt_color_suffix         ''
set -g __fish_git_prompt_color_branch         $__rice_accent
set -g __fish_git_prompt_color_branch_dirty   $__rice_bad
set -g __fish_git_prompt_color_branch_staged  $__rice_good
set -g __fish_git_prompt_color_upstream       $__rice_dim
# por defecto fish no muestra los estados; los pedimos explícitamente
set -g __fish_git_prompt_showuntrackedfiles   yes
set -g __fish_git_prompt_showdirtystate       yes
set -g __fish_git_prompt_showstashstate       yes
set -g __fish_git_prompt_show_upstream        yes
set -g __fish_git_prompt_showcolorhints       yes
set -g __fish_git_prompt_show_informative_status yes

# --- prompt ---
function fish_prompt --description 'prompt con path, git y error'
    set -l last $status
    set -l norm   (set_color normal)
    set -l accent (set_color --bold $__rice_accent)
    set -l bad    (set_color --bold $__rice_bad)

    set -l cwd (prompt_pwd -d 3)
    set -l suffix ''
    if functions -q fish_is_root_user; and fish_is_root_user
        set cwd $bad$cwd
        set suffix $bad'#'
    else
        set cwd $accent$cwd
    end

    # marca de error: sólo aparece si el último comando salió distinto de 0
    set -l marker ''
    if test $last -ne 0
        set marker $bad'✗'
    end

    printf '%s❯%s %s%s%s %s%s %s' \
        $accent $norm \
        $cwd $suffix $norm \
        (fish_vcs_prompt ' %s') $norm \
        $marker $norm
end

function fish_right_prompt --description 'reloj a la derecha'
    printf '%s%s%s' (set_color $__rice_dim) (date '+%H:%M') (set_color normal)
end

function fish_title --description 'título de la pestaña de kitty'
    set -l title (prompt_pwd -d 1)
    set -l vcs (fish_vcs_prompt '%s' | string collect | string trim)
    if test -n "$vcs"
        printf '%s %s' $title $vcs
    else
        printf '%s' $title
    end
end

# --- keybindings lindos ---
function fish_user_key_bindings
    # ctrl+izq / ctrl+der en terminal: matar/recorrer palabras
    bind \e\[1\;5D backward-kill-word
    bind \e\[1\;5C kill-word
    # ctrl+l no 清 la pantalla cuando hay texto: limpio, lo usa fish
end

# --- abreviaturas ---
abbr --add --global g    git
abbr --add --global gs   'git status -sb'
abbr --add --global ga   'git add'
abbr --add --global gaa  'git add --all'
abbr --add --global gco  'git checkout'
abbr --add --global gb   'git branch'
abbr --add --global gd   'git diff'
abbr --add --global gds  'git diff --staged'
abbr --add --global gl   'git log --oneline --graph --decorate -20'
abbr --add --global gc   'git commit -m'
abbr --add --global gp   'git push'
abbr --add --global gpl  'git pull'
abbr --add --global gf   'git fetch'
abbr --add --global gst  'git stash'

abbr --add --global reload 'source ~/.config/fish/config.fish'
abbr --add --global cls     'clear; printf "\033c"'
abbr --add --global md      'mkdir -p'
abbr --add --global ll      'ls -lh'
abbr --add --global la      'ls -lah'
abbr --add --global l       'ls -lh'

# nano es el editor que quedó configurado en yazi
set -gx EDITOR nano
set -gx VISUAL nano
