<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Linux Scripts — Documentation</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Merriweather:ital,wght@0,300;0,400;0,700;0,900;1,300;1,400&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }

    :root {
      --bg: #0a0c10;
      --bg-card: #12141a;
      --bg-card-hover: #181b24;
      --text: #e4e4e7;
      --text-muted: #8b8d97;
      --accent: #6ee7b7;
      --accent-dim: #34d399;
      --accent-glow: rgba(110, 231, 183, 0.08);
      --border: #1e2230;
    }

    body {
      font-family: 'Inter', sans-serif;
      background: var(--bg);
      color: var(--text);
      min-height: 100vh;
      overflow-x: hidden;
    }

    .container {
      max-width: 800px;
      margin: 0 auto;
      padding: 40px 24px 100px;
    }

    .back-nav {
      padding: 24px 0;
      border-bottom: 1px solid var(--border);
      margin-bottom: 48px;
    }
    .back-nav a {
      color: var(--accent);
      text-decoration: none;
      font-size: 0.9em;
      font-weight: 500;
    }
    .back-nav a:hover {
      text-decoration: underline;
    }

    h1 {
      font-family: 'Merriweather', Georgia, serif;
      font-size: 2.5em;
      font-weight: 900;
      letter-spacing: -0.02em;
      margin-bottom: 8px;
      background: linear-gradient(135deg, #fff 0%, var(--accent) 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }
    .subtitle {
      color: var(--text-muted);
      font-size: 1.05em;
      margin-bottom: 40px;
    }

    .section {
      margin-bottom: 48px;
      padding: 24px;
      background: var(--bg-card);
      border: 1px solid var(--border);
      border-radius: 16px;
      border-left: 4px solid var(--accent);
    }
    .section h2 {
      font-family: 'Merriweather', Georgia, serif;
      font-size: 1.4em;
      font-weight: 700;
      margin-bottom: 12px;
      color: var(--accent);
    }
    .section p {
      color: var(--text-muted);
      line-height: 1.8;
      margin-bottom: 12px;
    }

    .features {
      list-style: none;
      margin: 16px 0;
    }
    .features li {
      color: var(--text-muted);
      padding: 6px 0 6px 20px;
      position: relative;
      font-size: 0.92em;
      line-height: 1.6;
    }
    .features li::before {
      content: '→';
      position: absolute;
      left: 0;
      color: var(--accent);
      font-weight: 600;
    }

    code {
      font-family: 'Courier New', monospace;
      background: var(--bg);
      padding: 2px 6px;
      border-radius: 4px;
      font-size: 0.88em;
      color: var(--accent);
    }

    .callout {
      background: var(--bg);
      border: 1px solid var(--border);
      padding: 14px 18px;
      border-radius: 8px;
      margin: 16px 0;
    }
    .callout p {
      color: var(--text);
      font-size: 0.9em;
      margin: 0;
    }

    .requirements {
      margin-top: 16px;
      padding-top: 16px;
      border-top: 1px solid var(--border);
    }
    .requirements h3 {
      font-size: 0.85em;
      text-transform: uppercase;
      letter-spacing: 0.12em;
      color: var(--text-muted);
      margin-bottom: 8px;
      font-weight: 600;
    }
  </style>
</head>
<body>

  <div class="container">
    <div class="back-nav">
      <a href="../../linux/index.html">← Back to Linux Tools</a>
    </div>

    <h1>Linux Desktop Utilities</h1>
    <p class="subtitle">A collection of shell scripts for Linux Mint / Cinnamon desktops.</p>

    <div class="section" id="read-highlighted">
      <h2>📄 read-highlighted.sh</h2>
      <p>Continuously poll a screen region to watch for highlighted/selected text and automatically read it aloud using the system text-to-speech engine. Select an area on screen and it will monitor for text changes, reading new content as you scroll or switch documents.</p>
      <ul class="features">
        <li>Continuous polling of a screen region</li>
        <li>Auto-detects text changes as you scroll</li>
        <li>Reads text aloud via system TTS engine</li>
        <li>Draggable area selection</li>
        <li>Stops when you kill the process or move the region</li>
      </ul>
      <div class="callout">
        <p><strong>Output:</strong> Reads text aloud — no file output. Requires <code>espeak</code> or <code>say</code>.</p>
      </div>
      <div class="requirements">
        <h3>Requirements</h3>
        <p><code>xdotool</code>, <code>xclip</code>, <code>espeak</code> (or <code>say</code>)</p>
      </div>
    </div>

    <div class="section" id="quickvid">
      <h2>🎬 QuickVid_v7.sh</h2>
      <p>Record any area of your screen in MP4 format with optional audio (system, microphone, or headphones) and timer support. Select a draggable region on screen, choose your audio source, and hit record.</p>
      <ul class="features">
        <li>Draggable area selection with crosshair cursor</li>
        <li>30 FPS H.264 video encoding</li>
        <li>Optional system audio, microphone, or Bluetooth headphone capture</li>
        <li>Timer support and PID-based toggle (run again to stop)</li>
      </ul>
      <div class="callout">
        <p><strong>Output:</strong> Saves to <code>~/Videos/</code></p>
      </div>
      <div class="requirements">
        <h3>Requirements</h3>
        <p><code>ffmpeg</code>, <code>xdotool</code>, <code>zenity</code></p>
      </div>
    </div>

    <div class="section" id="quickaudio">
      <h2>🎙️ quickaudio_v3.sh</h2>
      <p>Record system audio, microphone, or a mix as MP3 files. Choose your source, set a timer if desired, and start recording. Run the script again to stop.</p>
      <ul class="features">
        <li>System audio, microphone, or mixed input</li>
        <li>Optional timer</li>
        <li>Custom or auto-named files</li>
        <li>PID-based toggle (run again to stop)</li>
      </ul>
      <div class="callout">
        <p><strong>Output:</strong> Saves to <code>~/Video/Audio/</code> as MP3</p>
      </div>
      <div class="requirements">
        <h3>Requirements</h3>
        <p><code>ffmpeg</code>, <code>zenity</code></p>
      </div>
    </div>

    <div class="section" id="ocr">
      <h2>🔍 ocr_multi.sh</h2>
      <p>Capture a screen region and extract text using Tesseract OCR. Supports English, Spanish, French, German, Italian, and Portuguese alphabet letters. The result is copied to the clipboard automatically.</p>
      <ul class="features">
        <li>Region selection with crosshair cursor</li>
        <li>Multi-language support (6 languages)</li>
        <li>Clipboard output — paste directly</li>
        <li>Great for extracting text from images or documents on screen</li>
      </ul>
      <div class="callout">
        <p><strong>Output:</strong> Copied to clipboard. Select a region and the extracted text is ready to paste.</p>
      </div>
      <div class="requirements">
        <h3>Requirements</h3>
        <p><code>tesseract-ocr</code>, <code>tesseract-ocr-eng</code>, <code>imagemagick</code>, <code>xdotool</code>, <code>xclip</code></p>
      </div>
    </div>

    <div class="section" id="launcher">
      <h2>🚀 launcher_v3.sh</h2>
      <p>Create, edit, and delete .desktop launchers for any executable script. Build launchers step-by-step, assign icons, and place them on your desktop or application menu.</p>
      <ul class="features">
        <li>Create launchers from .sh, .py, .bash, .pl, .js, .rb, .perl, .lua, .tcl scripts</li>
        <li>Edit or delete existing launchers</li>
        <li>Custom icons and descriptions</li>
        <li>Symlinks in ~/bin/ and .desktop files in ~/.local/share/applications/</li>
      </ul>
      <div class="callout">
        <p><strong>Output:</strong> Creates system-integrated launchers you can use from menus or desktop.</p>
      </div>
      <div class="requirements">
        <h3>Requirements</h3>
        <p><code>zenity</code>, <code>xdotool</code></p>
      </div>
    </div>

    <div class="section" id="imageclipper">
      <h2>✂️ ImageClipper.sh</h2>
      <p>Capture a selected screen region and save as PNG — either to the clipboard (paste-ready) or to either a named file or a timestamped file.</p>
      <ul class="features">
        <li>Region selection with crosshair cursor</li>
        <li>Clipboard or file output</li>
        <li>Notification confirmation</li>
      </ul>
      <div class="callout">
        <p><strong>Output:</strong> Clipboard or <code>~/Pictures/Screenshots/</code> as PNG</p>
      </div>
      <div class="requirements">
        <h3>Requirements</h3>
        <p><code>scrot</code>, <code>xdotool</code>, <code>xclip</code>, <code>libnotify-bin</code></p>
      </div>
    </div>

  </div>

</body>
</html>
