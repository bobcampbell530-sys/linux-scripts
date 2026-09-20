#!/bin/bash

# Ask user: clipboard or file?
CHOICE=$(zenity --list \
  --title="ImageClipper Destination" \
  --text="Where do you want to save the screenshot?" \
  --column="Option" \
  "Clipboard" \
  "File" \
  --width=300 --height=200)

# Exit if user cancels
[ -z "$CHOICE" ] && exit 0

echo "Screenshot tool running: select area with mouse"
sleep 1

if [ "$CHOICE" = "Clipboard" ]; then
    # Save to clipboard
    import png:- | xclip -selection clipboard -t image/png
    notify-send "Screenshot copied" "Image saved to clipboard"
else
    # Save to file
    DIR="$HOME/Pictures/Screenshots"
    mkdir -p "$DIR"
    FILE="$DIR/$(date +%Y-%m-%d_%H%M%S).png"
    import "$FILE"
    
    if [[ -s "$FILE" ]]; then
        notify-send "Screenshot saved" "$FILE"
    fi
fi
