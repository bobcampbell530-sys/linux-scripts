#!/bin/bash

# Ask for language (single column so Zenity returns ONLY the code)
LANG_CODE=$(zenity --list \
  --title="Select OCR Language" \
  --column="Code" \
  eng spa fra deu ita por)

# If user cancels
if [ -z "$LANG_CODE" ]; then
  exit 0
fi

# Capture screenshot area
rm -f /tmp/ocr_multi.png
gnome-screenshot -a -f /tmp/ocr_multi.png

# Make sure it was created
if [ ! -s /tmp/ocr_multi.png ]; then
  notify-send "OCR" "Screenshot failed!"
  exit 1
fi

# Run Tesseract OCR
tesseract /tmp/ocr_multi.png /tmp/ocr_multi_output -l "$LANG_CODE" 2>/tmp/ocr_multi_error.log

# Put into clipboard
if [ -s /tmp/ocr_multi_output.txt ]; then
  xclip -selection clipboard < /tmp/ocr_multi_output.txt
  notify-send "OCR" "Copied to clipboard!"
else
  notify-send "OCR ERROR" "OCR produced no text"
  cat /tmp/ocr_multi_error.log
fi
