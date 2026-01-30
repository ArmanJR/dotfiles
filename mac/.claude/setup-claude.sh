#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETTINGS_FILE="$HOME/.claude/settings.json"
SOURCE_SETTINGS_FILE="$SCRIPT_DIR/settings.json"
CLAUDE_STATUSLINE_FILE="$HOME/.claude/statusline.sh"
SOURCE_STATUSLINE_FILE="$SCRIPT_DIR/statusline.sh"

echo "Setting up Claude Code..."

mkdir -p "$HOME/.claude"

echo "Copying Claude Code settings..."
if [ -f "$CLAUDE_SETTINGS_FILE" ]; then
    cp "$CLAUDE_SETTINGS_FILE" "$CLAUDE_SETTINGS_FILE.backup"
    echo "   Backed up existing settings to $CLAUDE_SETTINGS_FILE.backup"
fi

if [ ! -f "$SOURCE_SETTINGS_FILE" ]; then
    echo "Error: Source settings file not found at $SOURCE_SETTINGS_FILE"
    exit 1
fi

cp "$SOURCE_SETTINGS_FILE" "$CLAUDE_SETTINGS_FILE"
echo "Claude Code settings updated"

echo "Copying statusline.sh..."
if [ ! -f "$SOURCE_STATUSLINE_FILE" ]; then
    echo "Error: Source statusline.sh not found at $SOURCE_STATUSLINE_FILE"
    exit 1
fi

cp "$SOURCE_STATUSLINE_FILE" "$CLAUDE_STATUSLINE_FILE"
chmod +x "$CLAUDE_STATUSLINE_FILE"
echo "statusline.sh copied and made executable"

echo ""
echo "Setup complete!"
echo ""
