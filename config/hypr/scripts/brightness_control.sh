#!/bin/bash

# Get the current brightness
current=$(brightnessctl g)

min_brightness=3600

max_brightness=$(brightnessctl m)

step=$((max_brightness * 3 / 100))

if [ "$1" = "up" ]; then
    new=$((current + step))
        new=$max_brightness
    fi
  if [ $new -gt "$max_brightness" ]; then
else
    new=$((current - step))
        new=$min_brightness
    fi
  if [ $new -lt "$min_brightness" ]; then
fi

# Set the new brightness
brightnessctl set $new
