#!/bin/bash
# Claude hook: read assistant responses aloud via Chatterbox TTS
# Controlled by flag file ~/.claude/tts-enabled

[ -f ~/.claude/tts-enabled ] || exit 0

INPUT=$(cat)
TEXT=$(echo "$INPUT" | jq -r '.last_assistant_message // empty')

[ -z "$TEXT" ] && exit 0

curl -s -X POST 'http://127.0.0.1:8855/tts?claude=1' \
  -H 'Content-Type: application/json' \
  -d "$(jq -n --arg text "$TEXT" '{text: $text}')" \
  > /dev/null 2>&1 &

exit 0
