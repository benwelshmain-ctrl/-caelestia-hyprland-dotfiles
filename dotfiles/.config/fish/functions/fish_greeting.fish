function fish_greeting
    if not set -q TMUX; and not set -q NVIM
        fastfetch
    end
end
