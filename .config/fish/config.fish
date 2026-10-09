function fastfetch --description 'Mostrar la imagen de jonaszfetch y los datos del sistema'
    command fastfetch --config "$HOME/.config/fastfetch/config.jsonc" \
        --pipe false
end

set -gx GDK_BACKEND "wayland,x11"
set -gx QT_QPA_PLATFORM "wayland;xcb"

alias f 'fastfetch'
alias ff 'fastfetch'

if status is-interactive
   printf '\n'
   fastfetch
   printf '\n'
end

starship init fish | source
