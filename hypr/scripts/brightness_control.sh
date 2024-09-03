#!/bin/bash

# Get the current brightness
current=$(brightnessctl g)

min_brightness=3600

max_brightness=$(brightnessctl m)

step=$((max_brightness * 3 / 100))

if [ "$1" = "up" ]; then
    new=$((current + step))
    if [ $new -gt $max_brightness ]; then
        new=$max_brightness
    fi
else
    new=$((current - step))
    if [ $new -lt $min_brightness ]; then
        new=$min_brightness
    fi
fi

# Set the new brightness
brightnessctl set $new
