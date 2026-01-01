function ag
    # Capture from the real terminal and throw the output away
    # (The Agent still 'sees' the result of the function call)
    cat </dev/tty >/dev/null
end
