# Linux Scripts

A collection of shell scripts and Python GUI applications for Linux Mint / Cinnamon desktops.

## Launcher

Run `video-tools` to launch a menu-based interface for all 4 video editing tools at once.

## Tools

### Shell Scripts

| Script | Description |
|--------|-------------|
| [read-highlighted.sh](read-highlighted.sh) | Read highlighted text aloud using Piper TTS |
| [quickaudio_v3.sh](quickaudio_v3.sh) | Record system audio, microphone, or mix as MP3 |
| [QuickVid_v7.sh](QuickVid_v7.sh) | Record screen video with optional audio |
| [launcher_v3.sh](launcher_v3.sh) | Create desktop launchers for any script |
| [ImageClipper.sh](ImageClipper.sh) | Screenshot tool with clipboard/file output |
| [ocr_multi.sh](ocr_multi.sh) | OCR text from screen region |
| [sys-temp.sh](sys-temp.sh) | Monitor CPU temperatures in real time |

### Video Editing Tools (Python + Tkinter)

| Script | Description |
|--------|-------------|
| [video-cutter](video-cutter) | Cut out unwanted sections from video files |
| [video-joiner](video-joiner) | Join multiple videos into one |
| [video-resizer](video-resizer) | Batch reduce file sizes for all videos in a directory |
| [video-speeder](video-speeder) | Change playback speed (25%–200%) with natural audio |
| [video-meta](video-meta) | Batch edit Artist/Album metadata tags (20+ formats incl. MKV) |

Run `video-tools` for a unified menu launcher.

## Requirements

- **Linux**: `ffmpeg` + `ffprobe` (for video tools), `python3` with `tkinter`
- **macOS**: `brew install ffmpeg` and `bash video-tools.sh` (macOS ships with bash 3.2 by default, which lacks associative array support)
- **Windows**: Not natively supported — use WSL2

## Notes

- All video tools leave the original file unmodified.
- Video tools use FFmpeg under the hood — re-encode with quality presets to control output size.
- Shell scripts are designed for Linux Mint / Cinnamon desktop environments.
