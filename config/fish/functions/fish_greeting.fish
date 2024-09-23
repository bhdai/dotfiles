function fish_greeting
    if not status is-interactive
        exit
    end
    colorscript -e alpha
end
