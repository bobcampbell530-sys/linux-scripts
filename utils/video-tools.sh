#!/usr/bin/env bash
# video-tools — launchpad for the video utility scripts
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOOLS=(video-cutter video-joiner video-meta video-resizer video-speeder)

# Check that all tools exist
missing=()
for i in "${!TOOLS[@]}"; do
  if [[ ! -x "$SCRIPT_DIR/${TOOLS[$i]}" ]]; then
    missing+=("${TOOLS[$i]}")
  fi
done

if (( ${#missing[@]} )); then
  echo "⚠ Missing executable(s): ${missing[*]}"
  echo "Please make sure they exist in $SCRIPT_DIR and are executable."
  exit 1
fi

echo ""
echo "  ┌──────────────────────────────────────────┐"
echo "  │         Video Utility Launcher           │"
echo "  └──────────────────────────────────────────┘"
echo ""
echo "  Select a tool:"
for i in "${!TOOLS[@]}"; do
  echo "  [$((i+1))] ${TOOLS[$i]}"
done
echo "  [q]  Quit"
echo ""
read -rp "  → " choice
echo ""

case "$choice" in
  [1-5])
    echo "Launching ${TOOLS[$((choice-1))]}…"
    exec "$SCRIPT_DIR/${TOOLS[$((choice-1))]}"
    ;;
  q|Q)
    echo "Bye."
    exit 0
    ;;
  *)
    echo "Invalid option. Nothing to do."
    exit 1
    ;;
esac
