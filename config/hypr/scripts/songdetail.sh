#!/bin/bash

song_info=$(playerctl metadata --format '{{title}}      {{artist}}')

# if the artist is missing, append a non-breaking space to keep layout
if [[ "$song_info" =~ [[:space:]]*$ ]]; then
  song_info="${song_info} "
fi

echo "$song_info"
