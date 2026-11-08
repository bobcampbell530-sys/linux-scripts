#!/usr/bin/env bash

VOICE_MODEL="$HOME/.local/share/piper-voices/en/en_US/hfc_male/medium/en_US-hfc_male-medium.onnx"
PIPER_BIN="piper"

DEFAULT_SPEED_INT=7
DEFAULT_SPEED=$(awk -v val="$DEFAULT_SPEED_INT" 'BEGIN {printf "%.1f", val / 10}')

TEMP_AUDIO="/tmp/piper_audio.wav"

# Get highlighted text once
text=$(xclip -selection primary -o 2>/dev/null || echo "")

if [[ -z "$text" ]]; then
    echo "No highlighted text found. Exiting."
    exit 0
fi

cleaned=$(echo "$text" | tr -s '\n\r\t' ' ' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

if [[ ${#cleaned} -lt 5 ]]; then
    echo "Selection too short. Exiting."
    exit 0
fi

echo "Detected: ${cleaned:0:60}..."

read -r -p "Speed (default $DEFAULT_SPEED_INT) → " speed_input

if [[ -z "$speed_input" ]]; then
    speed="$DEFAULT_SPEED"
else
    speed=$(awk -v val="$speed_input" 'BEGIN {printf "%.1f", val / 10}')
fi

# Generate and play speech
echo "$cleaned" | "$PIPER_BIN" \
    --model "$VOICE_MODEL" \
    --length-scale "$speed" \
    --output-file "$TEMP_AUDIO"

mpv --no-config --no-video --force-window=no "$TEMP_AUDIO"
rm -f "$TEMP_AUDIO"

# Close only this terminal window using xdotool
WIN_ID=$(xdotool search --pid $PPID 2>/dev/null | head -1)
if [[ -n "$WIN_ID" ]]; then
    xdotool windowclose "$WIN_ID" 2>/dev/null
fi
exit 0
