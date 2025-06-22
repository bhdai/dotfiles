#!/bin/bash

player=$(playerctl -l 2>/dev/null | head -n 1)
title=$(playerctl metadata --format '{{title}}' 2>/dev/null)
artist=$(playerctl metadata --format '{{artist}}' 2>/dev/null)

if [[ -z "$title" ]]; then
 exit 0
fi

case "$player" in
*spotify*) icon="" ;;
*firefox*) icon="" ;;
*chrome* | *chromium*) icon="" ;;
*) icon="" ;; # fallback to headphone
esac

# output format
if [[ -n "$artist" ]]; then
 echo "$title  $icon    $artist"
else
 echo "$title  $icon " # non-breaking space after icon
fi
