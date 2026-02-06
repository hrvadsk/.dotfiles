#!/bin/bash

# Wallpaper selector for fuzzel with image preview in notification
# Requires: fuzzel, swww (awww), notify-send (with image support)

# Directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Wallpaper directory '$WALLPAPER_DIR' does not exist"
    exit 1
fi

# Find all image files in wallpaper directory
images=$(find "$WALLPAPER_DIR" -type f \( \
    -iname "*.jpg" -o \
    -iname "*.jpeg" -o \
    -iname "*.png" -o \
    -iname "*.webp" -o \
    -iname "*.bmp" \
\) -printf "%f\n" | sort)

# Check if any images were found
if [ -z "$images" ]; then
    echo "No images found in $WALLPAPER_DIR"
    exit 1
fi

# Count number of images
image_count=$(echo "$images" | wc -l)

# Determine fuzzel arguments based on count
if [ "$image_count" -lt 15 ]; then
    # Use -l flag with the count if less than 15
    selected=$(echo "$images" | fuzzel --dmenu --prompt "Wallpaper: " -l "$image_count")
else
    # Don't use -l flag if 15 or more
    selected=$(echo "$images" | fuzzel --dmenu --prompt "Wallpaper: ")
fi

# Exit if nothing selected
if [ -z "$selected" ]; then
    exit 0
fi

# Get full path to selected wallpaper
wallpaper_path="$WALLPAPER_DIR/$selected"

# Change wallpaper using awww
swww img "$wallpaper_path" -t random --transition-duration 1 --transition-fps 144

# Save current wallpaper choice to a file
echo "$wallpaper_path" > "$HOME/.current_wallpaper"

# Send notification with image preview
notify-send "Wallpaper Changed" "$selected" \
    --icon="$wallpaper_path" \
    --urgency=low \
    2>/dev/null
