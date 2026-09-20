#!/bin/bash
# Directory for .desktop files
DESKTOP_DIR="$HOME/.local/share/applications"
BIN_DIR="$HOME/bin"
UTILS_DIR="$HOME/bin/utils"
ICON_FOLDER="$HOME/Icons/launchers"
mkdir -p "$DESKTOP_DIR" "$BIN_DIR" "$UTILS_DIR" "$ICON_FOLDER"
# List all .desktop files
FILES=$(find "$DESKTOP_DIR" -maxdepth 1 -type f -name "*.desktop" 2>/dev/null | sort)
# Build list for zenity (basename as display, full path as value)
FILE_LIST=()
while IFS= read -r file; do
    BASE_NAME=$(basename "$file")
    FILE_LIST+=("$BASE_NAME" "$file")
done <<< "$FILES"
# Main selection: choose file or create new
OPTIONS=()
if [ -n "$FILES" ]; then
    OPTIONS+=("Edit existing" "Edit")
    OPTIONS+=("Delete existing" "Delete")
fi
OPTIONS+=("Create new launcher" "Create")
CHOICE=$(zenity --list \
    --title="Manage Launchers" \
    --text="What would you like to do?" \
    --column="Action" --column="Type" --hide-column=2 --print-column=2 \
    --width=500 \
    --height=300 \
    "${OPTIONS[@]}")
if [ -z "$CHOICE" ]; then
    zenity --info --text="Cancelled."
    exit 0
fi
case "$CHOICE" in
    "Edit")
        if [ -z "$FILES" ]; then
            zenity --info --text="No .desktop files found."
            exit 0
        fi
        SELECTED=$(zenity --list \
            --title="Select File to Edit" \
            --text="Choose a .desktop file:" \
            --column="File Name" --column="Full Path" --hide-column=2 --print-column=2 \
            --width=600 \
            --height=400 \
            "${FILE_LIST[@]}")
        [ -z "$SELECTED" ] && exit 0
        if command -v xed >/dev/null; then
            xed "$SELECTED" &
        elif command -v gedit >/dev/null; then
            gedit "$SELECTED" &
        elif command -v nano >/dev/null; then
            nano "$SELECTED"
        else
            zenity --error --text="No editor found (xed/gedit/nano)."
            exit 1
        fi
        zenity --info --text="Opened for editing."
        ;;
    "Delete")
        if [ -z "$FILES" ]; then
            zenity --info --text="No .desktop files found."
            exit 0
        fi
        SELECTED=$(zenity --list \
            --title="Select File to Delete" \
            --text="Choose a .desktop file to delete:" \
            --width=600 \
            --height=400 \
            --column="File Name" --column="Full Path" --hide-column=2 --print-column=2 \
            "${FILE_LIST[@]}")
        [ -z "$SELECTED" ] && exit 0
        zenity --question --text="Delete $(basename "$SELECTED")?"
        if [ $? -eq 0 ]; then
            rm "$SELECTED"
            zenity --info --text="Deleted."
        else
            zenity --info --text="Cancelled."
        fi
        ;;
    "Create")
        # 1. Select script
        SCRIPT_PATH=$(zenity --file-selection \
            --title="Select script to launch" \
            --filename="$HOME/bin/utils/" \
            --file-filter="Scripts and executables | *.sh *.py *.bash *.zsh *.pl *.js *.rb *.perl *.lua *.tcl" \
            --file-filter="All executable files | *" \
            --file-filter="All files | *.*")
        [ -z "$SCRIPT_PATH" ] && { zenity --info --text="Cancelled."; exit 0; }
        SCRIPT_NAME=$(basename "$SCRIPT_PATH")
        APPNAME="${SCRIPT_NAME%.*}"
        # 2. Custom command name (symlink name)
        DEFAULT_CMD=$(echo "$APPNAME" | tr '[:upper:]' '[:lower:]' | sed 's/ /_/g')
        CMD_NAME=$(zenity --entry \
            --title="Command Name" \
            --text="Enter terminal command name (lowercase, no spaces):" \
            --entry-text="$DEFAULT_CMD")
        [ -z "$CMD_NAME" ] && { zenity --info --text="Cancelled."; exit 0; }
        # 3. Menu display name
        DEFAULT_MENU=$(echo "$APPNAME" | sed 's/_/ /g; s/^./\u&/; s/ ./\u&/g')
        MENU_NAME=$(zenity --entry \
            --title="Menu Name" \
            --text="Display name in menu:" \
            --entry-text="$DEFAULT_MENU")
        [ -z "$MENU_NAME" ] && { zenity --info --text="Cancelled."; exit 0; }
        # 3.5 New: Short description for Cinnamenu
        DEFAULT_DESC="Utility script for $MENU_NAME"
        DESCRIPTION=$(zenity --entry \
            --title="Description" \
            --text="Short description (appears under icon in Cinnamenu):" \
            --entry-text="$DEFAULT_DESC")
        # (empty description is allowed — just press OK or leave blank)
        # 4. Move script if needed
        TARGET_SCRIPT="$UTILS_DIR/$SCRIPT_NAME"
        if [ "$SCRIPT_PATH" != "$TARGET_SCRIPT" ]; then
            mv "$SCRIPT_PATH" "$TARGET_SCRIPT"
        fi
        chmod +x "$TARGET_SCRIPT"
        # 5. Create symlink
        SYMLINK="$BIN_DIR/$CMD_NAME"
        if [ -e "$SYMLINK" ]; then
            zenity --question --text="Command '$CMD_NAME' exists. Overwrite symlink?"
            [ $? -ne 0 ] && { zenity --info --text="Cancelled."; exit 0; }
            rm -f "$SYMLINK"
        fi
        ln -s "$TARGET_SCRIPT" "$SYMLINK"
        chmod +x "$SYMLINK"
        # 6. Optional icon
        ICON_PATH=$(zenity --file-selection \
            --title="Select icon (optional)" \
            --filename="/home/bob/Icons/" \
            --file-filter="Images | *.png *.svg *.ico")
        if [ -n "$ICON_PATH" ] && [ -f "$ICON_PATH" ]; then
            ICON_BASENAME=$(basename "$ICON_PATH")
            cp "$ICON_PATH" "$ICON_FOLDER/$ICON_BASENAME"
            ICON="$ICON_FOLDER/$ICON_BASENAME"
        else
            ICON="utilities-terminal"
        fi
        # 7. Create .desktop file — now with Comment
        DESKTOP_FILE="$DESKTOP_DIR/$CMD_NAME.desktop"
        cat > "$DESKTOP_FILE" <<EOL
[Desktop Entry]
Type=Application
Name=$MENU_NAME
Comment=$DESCRIPTION
Exec=$SYMLINK
Icon=$ICON
Terminal=true
Categories=Utility;
EOL
        chmod 644 "$DESKTOP_FILE"
        zenity --info --text="Launcher created!\nCommand: $CMD_NAME\nMenu name: $MENU_NAME"
        # Optional desktop shortcut
        zenity --question --text="Create desktop shortcut?"
        if [ $? -eq 0 ]; then
            cp "$DESKTOP_FILE" ~/Desktop/
            chmod +x ~/Desktop/"$CMD_NAME.desktop"
        fi
        ;;
esac
# Safest: just notify the system (no desktop restart needed)
update-desktop-database ~/.local/share/applications &>/dev/null
zenity --info --text="Done! Menu will update automatically."
