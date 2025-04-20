#!/bin/bash
set -euo pipefail

# Determine the real user's home directory (even when using sudo)
if [ -n "${SUDO_USER:-}" ]; then
    USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
    USER_HOME="$HOME"
fi

echo "Removing the old files..."
for file in * .*; do
    basename=$(basename "$file")
    
    if [[ ! -f "$USER_HOME/$basename" || "$basename" == "." || "$basename" == ".." || "$basename" == .git* ]]; then
        continue
    fi
    echo "Removing $USER_HOME/$basename..."
    # rm -f "$USER_HOME/$basename"
done

# echo "Linking the new files..."
# for file in *; do
#     if [ -f "$file" ]; then
#         echo "Linking $file to $USER_HOME/$file"
#         # ln -sf "$(pwd)/$file" "$USER_HOME/$file"
#     fi
# done