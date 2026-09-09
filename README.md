# linux-scripts

A collection of Linux desktop utility scripts for Mint X11 / Cinnamon.

## Tools

### QuickVid_v7.sh — Screen Video Recorder

Record any area of your screen in MP4 format with optional audio (system, microphone, or headphones) and timer support. Select a draggable region on screen, choose your audio source, and hit record.

- Draggable area selection with crosshair cursor
- 30 FPS H.264 video encoding
- Optional system audio, microphone, or Bluetooth headphone capture
- Timer support and PID-based toggle (run again to stop)
- Outputs to `~/Videos/`

### ImageClipper.sh — Screenshot Tool

Capture a selected screen region and save as PNG — either to the clipboard (paste-ready) or to either a named file or a timestamped file.

- Region selection with crosshair cursor
- Clipboard or file output
- Notification confirmation
- Outputs to clipboard or `~/Pictures/Screenshots/`

### ocr_multi.sh — Screen OCR

Capture a screen region and extract text using Tesseract OCR. Supports English, Spanish, French, German, Italian, and Portuguese alphabet letters. The result is copied to the clipboard automatically.

- Region selection
- Multi-language support
- Clipboard output
- Great for extracting text from images or documents on screen

### quickaudio_v3.sh — Audio Recorder

Record system audio, microphone, or a mix as MP3 files. Choose your source, set a timer if desired, and start recording. Run the script again to stop.

- System audio, microphone, or mixed input
- Optional timer
- Custom or auto-named files
- Outputs to `~/Video/Audio/`

### launcher_v3.sh — Launcher Manager

Create, edit, and delete `.desktop` launchers for any executable script. Build launchers step-by-step, assign icons, and place them on your desktop or application menu.

- Create launchers from `.sh`, `.py`, `.bash`, `.pl`, `.js`, `.rb`, `.perl`, `.lua`, `.tcl` scripts
- Edit or delete existing launchers
- Custom icons and descriptions
- Symlinks in `~/bin/` and `.desktop` files in `~/.local/share/applications/`

## Requirements

All scripts are designed for Linux desktops running X11 / Cinnamon (Linux Mint). Each tool lists its own dependencies in the included `README.md` file inside the zip archive. Common dependencies include:

- `zenity` — GUI dialogs
- `ffmpeg` — audio/video recording
- `libnotify-bin` — notifications

## Structure

Each zip archive contains:
- The shell script (`.sh`)
- A `README.md` with full usage instructions and dependency list

## License

Feel free to use these scripts as you wish.
