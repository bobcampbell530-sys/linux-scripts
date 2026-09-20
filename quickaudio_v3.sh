#!/bin/bash
# QuickAudio.sh — audio recorder for Mint X11 2025
# Records audio (MP3). Run again to stop the recording.

# --- ENVIRONMENT FIX FOR PANEL/LAUNCHER EXECUTION ---
SESSION_PID=$(pgrep -u "$(id -u)" "cinnamon-session|mate-session|xfce4-session|gnome-session|Xorg" | head -n 1)
if [ -n "$SESSION_PID" ] && [ -f "/proc/$SESSION_PID/environ" ]; then
    while IFS= read -r -d '' env_var || [ -n "$env_var" ]; do
        export "$env_var"
    done < "/proc/$SESSION_PID/environ"
fi

# Fallbacks just in case
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"
export DISPLAY="${DISPLAY:-:0}"
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:$PATH"

PIDFILE="/tmp/quickaudio.pid"

# 1. Check if a PID file exists
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        # QuickAudio is already running — send SIGINT (Ctrl+C) to ffmpeg 
        # This allows ffmpeg to flush and close the MP3 file properly.
        kill -2 "$OLD_PID" 2>/dev/null
        notify-send "QuickAudio" "Stopping recording..."
        # Don't delete PIDFILE here, the recording process will delete it when it finishes
        exit 0
    else
        rm "$PIDFILE"
    fi
fi

# 2. Clean up PID file on exit
trap 'rm -f "$PIDFILE"' EXIT

# Check dependencies
MISSING_DEPS=()
command -v ffmpeg &> /dev/null || MISSING_DEPS+=("ffmpeg")
command -v zenity &> /dev/null || MISSING_DEPS+=("zenity")
command -v pactl &> /dev/null || MISSING_DEPS+=("pulseaudio-utils")
command -v notify-send &> /dev/null || MISSING_DEPS+=("libnotify-bin")

if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    MISSING_LIST=$(printf '%s\n' "${MISSING_DEPS[@]}")
    if command -v zenity &> /dev/null; then
        zenity --error --text="Missing required packages:\n\n${MISSING_LIST}"
    else
        notify-send "QuickAudio Error" "Missing packages:\n$MISSING_LIST"
    fi
    exit 1
fi

# Optional timer
TIMER_SECS=""
TIMER_MSG=" (until you run QuickAudio again)"
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

mkdir -p "$HOME/Video/Audio"

notify-send "QuickAudio" "Recording${TIMER_MSG}\nRun QuickAudio again to stop"

# Audio source choice
AUDIO_CHOICE=$(zenity --list \
    --title="Audio Options" \
    --text="What audio do you want to record?" \
    --column="Option" \
    "System audio only" \
    "Microphone only" \
    "Both system + microphone" \
    "BX29 headphones" \
    --width=350 --height=280)

[ -z "$AUDIO_CHOICE" ] && exit 0

# Build audio input arguments using arrays to prevent word-splitting issues
AUDIO_ARGS=()
FILTER_ARGS=()

case "$AUDIO_CHOICE" in
    "System audio only")
        RUNNING_SINK=$(pactl list sinks short | grep RUNNING | head -1 | awk '{print $2}')
        if [ -z "$RUNNING_SINK" ]; then
            SYSTEM_MONITOR=$(pactl list sources short | grep "\.monitor" | head -1 | awk '{print $2}')
        else
            SYSTEM_MONITOR="${RUNNING_SINK}.monitor"
        fi
        
        if [ -z "$SYSTEM_MONITOR" ]; then
            zenity --error --text="Could not find system audio monitor.\nIs PulseAudio/Pipewire running?"
            exit 1
        fi
        AUDIO_ARGS+=("-f" "pulse" "-i" "$SYSTEM_MONITOR")
        ;;
    "Microphone only")
        AUDIO_ARGS+=("-f" "pulse" "-i" "default")
        ;;
    "Both system + microphone")
        RUNNING_SINK=$(pactl list sinks short | grep RUNNING | head -1 | awk '{print $2}')
        if [ -z "$RUNNING_SINK" ]; then
            SYSTEM_MONITOR=$(pactl list sources short | grep "\.monitor" | head -1 | awk '{print $2}')
        else
            SYSTEM_MONITOR="${RUNNING_SINK}.monitor"
        fi
        
        if [ -z "$SYSTEM_MONITOR" ]; then
            zenity --error --text="Could not find system audio monitor.\nIs PulseAudio/Pipewire running?"
            exit 1
        fi
        
        FILTER_ARGS+=("-filter_complex" "amix=inputs=2:duration=shortest:dropout_transition=2")
        AUDIO_ARGS+=("-f" "pulse" "-i" "$SYSTEM_MONITOR" "-f" "pulse" "-i" "default")
        ;;
    "BX29 headphones")
        HEADPHONE_SINK=$(pactl list sinks short | grep -i "BX29\|bluez.*CE_65_8F_1E_39_DA\|CE:65:8F:1E:39:DA" | head -1 | awk '{print $2}')
        if [ -z "$HEADPHONE_SINK" ]; then
            HEADPHONE_SINK=$(pactl list sinks short | grep "bluez" | head -1 | awk '{print $2}')
        fi
        if [ -n "$HEADPHONE_SINK" ]; then
            HEADPHONE_MONITOR="${HEADPHONE_SINK}.monitor"
            AUDIO_ARGS+=("-f" "pulse" "-i" "$HEADPHONE_MONITOR")
            notify-send "QuickAudio" "Recording from: $HEADPHONE_SINK"
        else
            notify-send "QuickAudio" "BX29 not found, using default"
            AUDIO_ARGS+=("-f" "pulse" "-i" "default")
        fi
        ;;
esac

# Filename
FILENAME_DIALOG=$(zenity --entry \
    --title="Name Recording (Optional)" \
    --text="Enter a name:\nLeave empty for default" \
    --width=400 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$FILENAME_DIALOG" ]; then
    SAFE_NAME=$(echo "$FILENAME_DIALOG" | sed 's/[^a-zA-Z0-9._ -]//g')
    OUTPUT="$HOME/Video/Audio/${SAFE_NAME}.mp3"
else
    OUTPUT="$HOME/Video/Audio/QuickAudio-$(date +%Y%m%d-%H%M%S).mp3"
fi

# Timer limit
if [ -n "$TIMER_SECS" ] && [ "$TIMER_SECS" -gt 0 ]; then
    TIME_LIMIT=("-t" "$TIMER_SECS")
else
    TIME_LIMIT=()
fi

# Run ffmpeg in background, capture its PID
ffmpeg "${TIME_LIMIT[@]}" \
    "${FILTER_ARGS[@]}" \
    "${AUDIO_ARGS[@]}" \
    -c:a libmp3lame -b:a 192k \
    -map_metadata -1 \
    "$OUTPUT" \
    -y \
    2>/tmp/quickaudio.log &

FFMPEG_PID=$!
echo "$FFMPEG_PID" > "$PIDFILE"

# Wait for ffmpeg to finish (either by timer or by being killed)
wait $FFMPEG_PID 2>/dev/null
EXIT_STATUS=$?

# Check if the file exists and has a size greater than 0
if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
    notify-send "QuickAudio Complete" "Saved: $OUTPUT"
else
    # If it failed, grab the last 15 lines of the log to show the user why
    ERROR_LOG=$(tail -n 15 /tmp/quickaudio.log)
    zenity --error --title="QuickAudio Error" --text="Recording failed or produced an empty file.\n\nffmpeg log:\n\n$ERROR_LOG"
fi
