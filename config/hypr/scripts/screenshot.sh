#!/bin/bash

shader=$(hyprshade current)

restore_shader() {
  if [ -n "$shader" ]; then
    hyprshade on "$shader"
  fi
}

# Take a screenshot based on the type
take_screenshot() {
  local type=$1
  local save_dir=$2
  local save_file=$3

  case $type in
  "area_clipboard")
    grimblast copy area
    ;;
  "area_file")
    grimblast save area "${save_dir}/${save_file}"
    ;;
  "screen_clipboard")
    grimblast copy screen
    ;;
  "screen_file")
    grimblast save screen "${save_dir}/${save_file}"
    ;;
  *)
    echo "Invalid screenshot type!"
    restore_shader
    exit 1
    ;;
  esac

  # If saving to a file, check if it was saved successfully
  if [ -f "${save_dir}/${save_file}" ]; then
    notify-send -a "screenshot" -i "${save_dir}/${save_file}" "Saved in ${save_dir}"
  else
    notify-send -a "screenshot" "Screenshot copied to clipboard"
  fi
}

# Main script execution
main() {
  # Temporary disable the shader
  hyprshade off

  # Wait for the shader effect to disable
  sleep 0.5

  # Define the save directory and file name
  save_dir=~/Pictures/Screenshots
  save_file=$(date +%Y-%m-%d_%H-%M-%S).png

  # Determine screenshot type from command-line argument
  screenshot_type=$1

  # Take the screenshot
  take_screenshot "$screenshot_type" "$save_dir" "$save_file"

  # Restore the shader
  restore_shader
}

main "$1"
