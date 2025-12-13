#!/bin/bash

# VS Code Extensions Installation Script
# This script installs all VS Code extensions listed in extensions.txt

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXTENSIONS_FILE="$SCRIPT_DIR/extensions.txt"

# Check if VS Code CLI is available
if ! command -v code &> /dev/null; then
    echo "Error: VS Code CLI 'code' command not found."
    echo "Please install VS Code and ensure the 'code' command is in your PATH."
    echo "On macOS, you can install it via: Command Palette > Shell Command: Install 'code' command in PATH"
    exit 1
fi

# Check if extensions file exists
if [ ! -f "$EXTENSIONS_FILE" ]; then
    echo "Error: extensions.txt not found at $EXTENSIONS_FILE"
    exit 1
fi

echo "Installing VS Code extensions..."
echo "================================"

# Read extensions from file and install
while IFS= read -r extension || [ -n "$extension" ]; do
    # Skip empty lines and comments
    if [ -z "$extension" ] || [[ "$extension" =~ ^#.* ]]; then
        continue
    fi

    echo "Installing: $extension"
    code --install-extension "$extension" --force
done < "$EXTENSIONS_FILE"

echo ""
echo "================================"
echo "All extensions installed successfully!"
echo ""
echo "Installed extensions:"
code --list-extensions
