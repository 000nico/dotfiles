function nvim --wraps nvim --description "Neovim wrapper with kitty padding reset"
    kitty @ set-spacing padding=0 2>/dev/null
    command nvim $argv
    kitty @ set-spacing padding=default 2>/dev/null
end
