#!/bin/bash

# Clipboard history manager for fuzzel with image preview
# Requires: fuzzel, cliphist, wl-clipboard, imagemagick, chafa (for terminal image preview)

# Check if cliphist is installed
if ! command -v cliphist &> /dev/null; then
    echo "Error: cliphist is not installed. Install with: yay -S cliphist"
    exit 1
fi

# Temporary directory for previews
TEMP_DIR="/tmp/cliphist-fuzzel"
mkdir -p "$TEMP_DIR"

# Get clipboard history
history=$(cliphist list)

if [ -z "$history" ]; then
    exit 0
fi

# Process history and create preview files
declare -a items
declare -A item_to_line

counter=0
while IFS= read -r line; do
    counter=$((counter + 1))
    id=$(echo "$line" | cut -d$'\t' -f1)
    
    # Check if it's an image
    if echo "$line" | cliphist decode | file --mime-type - | grep -q "image/"; then
        # Save image for preview
        img_path="$TEMP_DIR/${id}.png"
        echo "$line" | cliphist decode > "$img_path" 2>/dev/null
        
        # Create a text representation with image path for fuzzel
        # Fuzzel doesn't show images directly, but we can use special formatting
        display_text="Image $counter"
        items+=("$display_text")
        item_to_line["$display_text"]="$line"
    else
        # Text entry - show preview
        preview=$(echo "$line" | cliphist decode | head -c 60 | tr '\n' ' ')
        display_text="$preview"
        items+=("$display_text")
        item_to_line["$display_text"]="$line"
    fi
done <<< "$history"

# Count entries
entry_count=${#items[@]}

# Convert array to newline-separated string
menu=$(printf '%s\n' "${items[@]}")

# Select with fuzzel
if [ "$entry_count" -lt 15 ]; then
    selected=$(echo "$menu" | fuzzel --dmenu --prompt "Clipboard: " -l "$entry_count")
else
    selected=$(echo "$menu" | fuzzel --dmenu --prompt "Clipboard: ")
fi

if [ -z "$selected" ]; then
    exit 0
fi

# Get original line and copy to clipboard
original="${item_to_line[$selected]}"
echo "$original" | cliphist decode | wl-copy

# Cleanup old temp files
find "$TEMP_DIR" -type f -mtime +1 -delete 2>/dev/null
