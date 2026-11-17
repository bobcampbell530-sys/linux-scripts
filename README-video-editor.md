# video-editor.sh

A graphical video editor built with a bash wrapper and an HTML interface. Play a video, mark sections to cut out on a visual timeline, and it generates the ffmpeg commands for you.

## ⚠️ Important: Paths

The wrapper script (`video-editor.sh`) has a **hard-coded path** at the top:

```bash
cd /home/bob/bin || exit 1
```

You **must** change this to wherever you place `video-editor.sh` and `video-editor.html`. Otherwise the script won't find the HTML file and will exit.

## Requirements

- `bash`
- `ffmpeg` (for re-encoding)
- `python3` (for the local web server)
- A modern browser (Chrome, Firefox, Edge)

## Usage

1. Place both `video-editor.sh` and `video-editor.html` in the same directory.
2. Make the script executable:

```bash
chmod +x video-editor.sh
```

3. Run it:

```bash
./video-editor.sh
```

This starts a local Python HTTP server on `http://localhost:8000/` and opens the editor in your browser.

### Workflow

1. Click the upload area in the browser and select an MP4 or WebM video file.
2. The video loads in the player. Use **Mark Start** and **Mark End** to define sections to cut out. Each marked section appears as a red bar on the timeline.
3. The ffmpeg commands appear below. Copy them with the **Copy Commands** button.
4. Open a terminal in the folder containing the original video file, then paste and run the commands.

> **Important:** The generated ffmpeg commands must be run in the same folder as the video file, since they reference the original file by name.

> **Tip:** You can use Nautilus or Nemo to open a terminal in the right folder without typing a path. Right-click an empty space and choose **Open in Terminal**.

### Stopping the Server

Press **Ctrl+C** in the terminal to stop the server.

## How It Works

- Marked sections (red bars) are **cut out**. Everything else is kept.
- The generated ffmpeg commands re-encode the video to **H.264 + AAC** so cuts are **frame-accurate** at any timestamp (unlike stream-copy cuts which are limited to keyframes).
- Multiple non-contiguous cut sections are supported. Overlapping cuts are merged automatically.
- Output files are named `<originalname>_DONE.mp4`.

## Performance

Re-encoding is slower than stream-copy methods, but it allows precise cuts at any point in the video, not just at keyframes.
