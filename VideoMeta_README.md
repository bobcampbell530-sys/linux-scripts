# video-meta — Batch Metadata Editor

Batch edit **Artist** and **Album** metadata tags across an entire folder tree. Supports over 20 audio and video formats.

## Features

- **20+ format support**: MP3, FLAC, OGG, OGA, M4A, MP4, WAV, WMA, AAC, OPUS, MKV, APE, WV, TAK, MPC, AIFF, DSF, MPP, SPX, TTA
- **MKV video tags**: Reads/writes Artist and Album via `ffprobe` / `ffmpeg`
- **Auto-suggest**: Fills Artist/Album from folder name (handles `"Artist - Album"`, `"Album - Artist"`, Roman numerals, title-casing)
- **Batch apply**: Apply to selected rows or all files at once
- **Individual edit**: Double-click an Artist or Album cell to edit that file alone
- **Built-in file browser**: Navigate folders, select the one to scan — no external tools required
- **Cross-platform**: Works on Windows, macOS, and Linux

## Installation

Requires:
```bash
sudo apt install python3-tk python3-pip
pip3 install mutagen
```

## Usage

```bash
python3 ~/bin/video-meta
```

Or via bash alias (add to `~/.bashrc`):
```bash
dea() { ~/bin/video-meta "$@"; }
```

## How It Works

1. Use the built-in file browser to navigate to your music/video folder
2. Click **"Scan This Folder"** — audio/video files appear in the tree below
3. Enter an **Artist** and/or **Album** name in the fields above the tree
4. Select files (or leave unselected to apply to all)
5. Click **"Apply to Selected"** or **"Apply to All"**

The Artist and Album fields are auto-filled from your folder name. If the folder is named `"Daft Punk - Random Access Memories"`, it will suggest Artist: `Daft Punk`, Album: `Random Access Memories`.

## Format-Specific Tag Mapping

| Format | Artist Tag | Album Tag |
|--------|-----------|-----------|
| MP3 | TPE1 | TIT2 |
| FLAC | artist | album |
| OGG/Opus | artist | album |
| M4A/MP4 | \xa9ART | \xa9alb |
| WAV (ID3) | TPE1 | TIT2 |
| WMA (ASF) | Author | WM/AlbumTitle |
| MKV | ARTIST (via ffprobe) | ALBUM (via ffprobe) |

## MKV Support

MKV files are handled via `ffmpeg` / `ffprobe` since `mutagen` doesn't support Matroska containers:

- **Reading**: `ffprobe -print_format json -show_format` extracts `TAG:ARTIST` and `TAG:ALBUM`
- **Writing**: `ffmpeg -i input.mkv -metadata artist=... -metadata album=... -c copy output.mkv`
- No re-encoding — uses `-c copy` for lossless stream copy

## License

Feel free to use these scripts as you wish.
