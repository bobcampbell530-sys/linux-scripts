#!/bin/bash
# QuickVid.sh — perfect draggable-area video recorder for Mint X11 2025

# Define a PID file location
PIDFILE="/tmp/quickvid.pid"

# 1. Check if a PID file exists
if [ -f "$PIDFILE" ]; then
    if kill -0 $(cat "$PIDFILE") 2>/dev/null; then
        # QuickVid is already running — stop the recording
        FFMPEG_PID=$(pgrep -f "ffmpeg.*x11grab" | head -1)
        if [ -n "$FFMPEG_PID" ]; then
            kill "$FFMPEG_PID" 2>/dev/null
            sleep 1
        fi
        kill $(cat "$PIDFILE") 2>/dev/null
        notify-send "QuickVid" "Recording stopped"
        rm -f "$PIDFILE"
        exit 0
    else
        # Ghost PID file — clean up
        rm "$PIDFILE"
    fi
fi

# 2. Write our current Process ID to the file
echo $$ > "$PIDFILE"

# 3. CRITICAL: Delete PID file when script exits (even on crash)
trap 'rm -f "$PIDFILE"' EXIT

# Check all required dependencies
MISSING_DEPS=()
command -v slop &> /dev/null || MISSING_DEPS+=("slop")
command -v ffmpeg &> /dev/null || MISSING_DEPS+=("ffmpeg")
command -v zenity &> /dev/null || MISSING_DEPS+=("zenity")
command -v pactl &> /dev/null || MISSING_DEPS+=("pulseaudio-utils")
command -v notify-send &> /dev/null || MISSING_DEPS+=("libnotify-bin")

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    MISSING_LIST=$(printf '%s\n' "${MISSING_DEPS[@]}")
    if command -v zenity &> /dev/null; then
        zenity --error --text="Missing required packages:\n\n${MISSING_LIST}\n\nInstall with:\nsudo apt install ${MISSING_DEPS[*]}"
    else
        echo "ERROR: Missing required packages:"
        echo "$MISSING_LIST"
        echo ""
        echo "Install with: sudo apt install ${MISSING_DEPS[*]}"
    fi
    exit 1
fi

# Prompt for optional timer
TIMER_SECS=""
TIMER_MSG=" (until you run QuickVid again)"
TIMER_DIALOG=$(zenity --forms \
    --title="Recording Timer (Optional)" \
    --text="Enter recording duration (leave both empty for manual stop):\nPress Cancel for no timer" \
    --add-entry="Minutes" \
    --add-entry="Seconds" \
    --width=350 2>/dev/null)

if [ $? -eq 0 ]; then
    MINUTES=$(echo "$TIMER_DIALOG" | cut -d'|' -f1)
    SECONDS=$(echo "$TIMER_DIALOG" | cut -d'|' -f2)
    MINUTES=${MINUTES:-0}
    SECONDS=${SECONDS:-0}
    
    if [[ "$MINUTES" =~ ^[0-9]+$ ]] && [[ "$SECONDS" =~ ^[0-9]+$ ]]; then
        if [ "$SECONDS" -ge 60 ]; then
            zenity --error --text="Seconds must be between 0 and 59."
            exit 1
        fi
        
        if [ "$MINUTES" -gt 0 ] || [ "$SECONDS" -gt 0 ]; then
            TIMER_SECS=$((MINUTES * 60 + SECONDS))
            TIMER_MSG=" (Timer: ${MINUTES}m ${SECONDS}s)"
        fi
    else
        zenity --error --text="Timer values must be positive integers."
        exit 1
    fi
fi

mkdir -p "$HOME/Videos"
notify-send "QuickVid" "Click and drag to select the recording area${TIMER_MSG}"

geometry=$(slop -f "%w %h %x %y")
if [ -z "$geometry" ]; then
    notify-send "QuickVid" "Cancelled"
    exit 0
fi

read W H X Y <<< "$geometry"

AUDIO_CHOICE=$(zenity --list \
  --title="Audio Options" \
  --text="What audio do you want to record?" \
  --column="Option" \
  "No audio" \
  "System audio only" \
  "Microphone only" \
  "Both system + microphone" \
  "BX29 headphones" \
  --width=350 --height=280)

[ -z "$AUDIO_CHOICE" ] && exit 0

case "$AUDIO_CHOICE" in
    "System audio only")
        RUNNING_SINK=$(pactl list sinks short | grep RUNNING | head -1 | awk '{print $2}')
        if [ -z "$RUNNING_SINK" ]; then
            SYSTEM_MONITOR=$(pactl list sources short | grep "\.monitor" | head -1 | awk '{print $2}')
        else
            SYSTEM_MONITOR="${RUNNING_SINK}.monitor"
        fi
        AUDIO="-f pulse -i $SYSTEM_MONITOR"
        ;;
    "Microphone only")
        AUDIO="-f pulse -i default"
        ;;
    "Both system + microphone")
        RUNNING_SINK=$(pactl list sinks short | grep RUNNING | head -1 | awk '{print $2}')
        if [ -z "$RUNNING_SINK" ]; then
            SYSTEM_MONITOR=$(pactl list sources short | grep "\.monitor" | head -1 | awk '{print $2}')
        else
            SYSTEM_MONITOR="${RUNNING_SINK}.monitor"
        fi
        AUDIO="-f pulse -i $SYSTEM_MONITOR -f pulse -i default -filter_complex amerge=inputs=2"
        ;;
    "BX29 headphones")
        HEADPHONE_SINK=$(pactl list sinks short | grep -i "BX29\|bluez.*CE_65_8F_1E_39_DA\|CE:65:8F:1E:39:DA" | head -1 | awk '{print $2}')
        if [ -z "$HEADPHONE_SINK" ]; then
            HEADPHONE_SINK=$(pactl list sinks short | grep "bluez" | head -1 | awk '{print $2}')
        fi
        if [ -n "$HEADPHONE_SINK" ]; then
            HEADPHONE_MONITOR="${HEADPHONE_SINK}.monitor"
            AUDIO="-f pulse -i $HEADPHONE_MONITOR"
            notify-send "QuickVid" "Recording audio from: $HEADPHONE_SINK"
        else
            notify-send "QuickVid Warning" "BX29 headphones not found, using default audio"
            AUDIO="-f pulse -i default"
        fi
        ;;
    *)
        AUDIO=""
        ;;
esac

# Optionally name the recording
FILENAME_DIALOG=$(zenity --entry \
    --title="Name Recording (Optional)" \
    --text="Enter a name for this recording:\nLeave empty for default (date/time)" \
    --width=400 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$FILENAME_DIALOG" ]; then
    # Sanitize the filename — remove slashes and other problematic characters
    SAFE_NAME=$(echo "$FILENAME_DIALOG" | sed 's/[^a-zA-Z0-9._ -]//g')
    OUTPUT="$HOME/Videos/${SAFE_NAME}.mp4"
else
    OUTPUT="$HOME/Videos/QuickVid-$(date +%Y%m%d-%H%M%S).mp4"
fi

if [ -n "$TIMER_SECS" ] && [ "$TIMER_SECS" -gt 0 ]; then
    TIME_LIMIT="-t $TIMER_SECS"
else
    TIME_LIMIT=""
fi

notify-send "QuickVid" "Recording ${W}×${H} to $(basename "$OUTPUT")${TIMER_MSG}\n\nRun QuickVid again to stop"

ffmpeg -f x11grab -framerate 30 -video_size ${W}x${H} \
       -i :0.0+${X},${Y} $AUDIO $TIME_LIMIT -c:v libx264 -preset veryfast -crf 23 -c:a aac "$OUTPUT" 2>/tmp/quickvid.log

if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
    notify-send "QuickVid Complete" "Saved: $OUTPUT"
else
    notify-send "QuickVid Error" "Recording failed. Check /tmp/quickvid.log"
fi
