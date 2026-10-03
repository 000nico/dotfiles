function fastfetch --description 'Mostrar la imagen de jonaszfetch y los datos del sistema'
    kitten icat --z-index=-1 --place 66x14@0x0 --transfer-mode=file "$HOME/Pictures/fetchimage.png"
    command fastfetch --config "$HOME/.config/fastfetch/config.jsonc" --logo none --pipe false | sed 's/^/                              /'
end

alias f 'fastfetch'
alias ff 'fastfetch'

if status is-interactive
   printf '\n'
   fastfetch
   printf '\n'
end

starship init fish | source
starship init fish | source
starship init fish | source
