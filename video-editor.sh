#!/bin/bash

cd /home/bob/bin || exit 1

PORT=8000
URL="http://localhost:$PORT/video-editor.html"

if [ ! -f video-editor.html ]; then
    echo -e "\e[1;31m✗ video-editor.html not found in $(pwd)\e[0m"
    exit 1
fi

echo -e "\e[1;35m"
echo "╔════════════════════════════════════╗"
echo "║  VIDEO EDITOR SERVER STARTING      ║"
echo "╚════════════════════════════════════╝"
echo -e "\e[0m"

# If an old server (from a previous run) is still holding the port, stop it
free_port() {
    local pids pid cmd
    pids=$(ss -ltnp "sport = :$PORT" 2>/dev/null | grep -o 'pid=[0-9]*' | cut -d= -f2 | sort -u)
    [ -z "$pids" ] && return 0
    for pid in $pids; do
        cmd=$(ps -o args= -p "$pid")
        if [[ "$cmd" == *python* ]]; then
            echo -e "\e[1;33m↻ Stopping old server on port $PORT (pid $pid)\e[0m"
            kill "$pid" 2>/dev/null
        else
            echo -e "\e[1;31m✗ Port $PORT is used by a non-Python process:\e[0m $cmd"
            exit 1
        fi
    done
    sleep 0.5
}
free_port

# Start the server in the background FIRST, so the browser doesn't hit a dead port
python3 -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SERVER_PID=$!

cleanup() {
    kill "$SERVER_PID" 2>/dev/null
    echo -e "\n\e[1;33mServer stopped.\e[0m"
    exit 0
}
trap cleanup INT TERM HUP

# Wait until the server is actually accepting connections
for _ in $(seq 1 20); do
    (echo > /dev/tcp/127.0.0.1/$PORT) 2>/dev/null && break
    sleep 0.25
done

# If python died (e.g. port already in use), say so
sleep 0.3
if ! kill -0 "$SERVER_PID" 2>/dev/null; then
    echo -e "\e[1;31m✗ Server failed to start. Is port $PORT already in use?\e[0m"
    echo "  Check with: ss -ltnp | grep $PORT"
    exit 1
fi

if command -v xdg-open &> /dev/null; then
    xdg-open "$URL" >/dev/null 2>&1 &
    echo -e "\e[1;32m✓ Browser opened automatically!\e[0m"
else
    echo -e "\e[1;33m📹 Open your browser to:\e[0m"
    echo -e "\e[1;92m   $URL\e[0m"
fi

echo ""
echo -e "\e[1;31m⚠️  Press Ctrl+C to stop the server when done.\e[0m"
echo ""

wait "$SERVER_PID"
