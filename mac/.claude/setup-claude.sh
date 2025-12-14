#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CCSTATUSLINE_VERSION="2.0.23"
CLAUDE_SETTINGS_FILE="$HOME/.claude/settings.json"
CCSTATUSLINE_CONFIG_DIR="$HOME/.config/ccstatusline"
CCSTATUSLINE_CONFIG_FILE="$CCSTATUSLINE_CONFIG_DIR/settings.json"
SOURCE_SETTINGS_FILE="$SCRIPT_DIR/settings.json"

echo "Setting up Claude Code with ccstatusline..."

if ! command -v bun &> /dev/null; then
    echo "Error: bun is not installed. Please install bun first:"
    echo "   curl -fsSL https://bun.sh/install | bash"
    exit 1
fi

echo "Installing ccstatusline@$CCSTATUSLINE_VERSION..."
bun install -g ccstatusline@$CCSTATUSLINE_VERSION

if ! command -v ccstatusline &> /dev/null; then
    echo "Error: ccstatusline installation failed"
    exit 1
fi

echo "ccstatusline installed at: $(which ccstatusline)"

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

mkdir -p "$CCSTATUSLINE_CONFIG_DIR"

echo "Creating ccstatusline configuration..."
cat > "$CCSTATUSLINE_CONFIG_FILE" << 'EOF'
{
  "version": 3,
  "lines": [
    [
      {
        "id": "1",
        "type": "current-working-dir",
        "color": "brightBlack"
      },
      {
        "id": "5",
        "type": "git-branch",
        "color": ""
      },
      {
        "id": "4e187907-f2ae-4182-b9da-a6cb2cc4690c",
        "type": "model",
        "color": "brightBlack"
      },
      {
        "id": "3",
        "type": "context-percentage",
        "color": "white"
      }
    ],
    [],
    []
  ],
  "flexMode": "full-minus-40",
  "compactThreshold": 60,
  "colorLevel": 2,
  "inheritSeparatorColors": false,
  "globalBold": false,
  "powerline": {
    "enabled": false,
    "separators": [
      ""
    ],
    "separatorInvertBackground": [
      false
    ],
    "startCaps": [
      ""
    ],
    "endCaps": [
      ""
    ],
    "autoAlign": false,
    "theme": "nord-aurora"
  },
  "defaultPadding": " "
}
EOF

echo "ccstatusline configuration created"

echo ""
echo "Setup complete!"
echo ""
