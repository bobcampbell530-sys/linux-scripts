# QuickVid_v7.sh

A GUI screen video recorder for Linux desktops (Mint X11, Cinnamon, etc.). Lets you select a draggable area on screen to record, with optional audio and timer support. Records in MP4 format.

## What It Does

1. Checks if a recording is already running — if so, stops it gracefully.
2. Optionally sets a timer (minutes + seconds) or records manually.
3. Opens a crosshair cursor — click and drag to select the exact screen area to record.
4. Asks what audio to capture:
   - **No audio** — silent recording
   - **System audio only** — all desktop/system sounds
   - **Microphone only** — your microphone
   - **Both system + microphone** — mixed audio
   - **BX29 headphones** — audio from your Bluetooth headphones

> **INSTRUCTIONS for finding your headphones address:**
>   1. Open your Linux Menu and search for **Bluetooth** to find the first part
>      of your address. In my case, my BX29 headphones use `CE:65:8F:1E:39:DA`
>   2. Open a terminal and run: `pactl list cards short | grep -i bluez` to
>      confirm. In my case the second part is also `CE:65:8F:1E:39:DA`
>   3. Edit the line 132 of the QuickVid.sh script to reflect your bluetooth headphone address.

5. Optionally names the recording (default is timestamped).
6. Records the selected area at 30 FPS using ffmpeg (H.264 video, AAC audio).
7. Saves to `~/Videos/`.
8. Sends notifications at start and completion.

## Audio Source Options

| Option | Records |
|--------|---------|
| No audio | Silent video only |
| System audio only | All desktop/system sounds |
| Microphone only | Your microphone input |
| Both system + microphone | Mix of desktop audio and mic (via `amerge`) |
| BX29 headphones | Audio from your BX29 Bluetooth headphones |

## Dependencies

| Package | Provides |
|---------|----------|
| `ffmpeg` | Video encoding (H.264/AAC) |
| `slop` | Area selection tool |
| `zenity` | GUI dialogs |
| `pulseaudio-utils` | `pactl` for audio source discovery |
| `libnotify-bin` | `notify-send` notifications |

Install:
```bash
sudo apt install ffmpeg slop zenity pulseaudio-utils libnotify-bin
```

## Usage

Run from terminal or create a launcher for it:
```bash
QuickVid_v7.sh
```

To stop a running recording, run it again:
```bash
QuickVid_v7.sh
```

## How It Works

### PID-based toggle
- Stores its own PID in `/tmp/quickvid.pid`.
- First run: starts recording, writes PID.
- Second run: finds the ffmpeg process, kills it gracefully.

### Area selection
- Uses `slop` to let you draw a rectangle on screen.
- Returns width, height, X, Y coordinates.
- ffmpeg `x11grab` captures that exact region at 30 FPS.

### Video encoding
- H.264 with `libx264` (veryfast preset, CRF 23 — good quality/performance balance)
- AAC audio when audio source is selected
- Output: MP4 container

### Timer support
- If minutes or seconds are entered, wraps ffmpeg with `-t <seconds>` to auto-stop.

## Output

Files are saved as `~/Videos/QuickVid-YYYYMMDD-HHMMSS.mp4` or `~/Videos/<custom-name>.mp4`.
