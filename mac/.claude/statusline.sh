#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PERCENT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
SESSION_ID=$(echo "$input" | jq -r '.session_id')

# Lines changed
LINES_ADDED=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
LINES_REMOVED=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')

# Rate limit (Pro/Max only, may be absent)
RATE_5H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
[ -n "$RATE_5H" ] && RATE_5H=$(printf '%.0f' "$RATE_5H")

# Remove home path from DIR
DIR="${DIR#$HOME/}"

# Keep only the first word of MODEL and lowercase it
MODEL=$(echo "${MODEL%% *}" | tr '[:upper:]' '[:lower:]')

# Git branch (cached)
CACHE_FILE="/tmp/statusline-git-$SESSION_ID"
CACHE_MAX_AGE=5

if [ ! -f "$CACHE_FILE" ] || [ $(($(date +%s) - $(stat -f %m "$CACHE_FILE" 2>/dev/null || stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0))) -gt $CACHE_MAX_AGE ]; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        git branch --show-current > "$CACHE_FILE" 2>/dev/null
    else
        echo "" > "$CACHE_FILE"
    fi
fi
BRANCH=$(cat "$CACHE_FILE")
[ -n "$BRANCH" ] && GIT_BRANCH=" • $BRANCH" || GIT_BRANCH=""

MACHINE=$(hostname -s)

# Account: da = Max, su = Pro, else = nothing
EMAIL=$(jq -r '.oauthAccount.emailAddress // empty' ~/.claude.json 2>/dev/null)
ACCT=""
case "${EMAIL:0:2}" in
    da) ACCT="Max" ;;
    su) ACCT="Pro" ;;
esac

# Colors
YELLOW='\033[33m'
RESET='\033[0m'

# Build output
if [ "$PERCENT_USED" -ge 50 ]; then
    CTX_PART="${YELLOW}${PERCENT_USED}%${RESET}"
else
    CTX_PART="${PERCENT_USED}%"
fi
OUTPUT="$MACHINE • $DIR$GIT_BRANCH • $CTX_PART • $MODEL"

# Add lines changed if any
[ "$LINES_ADDED" -gt 0 ] || [ "$LINES_REMOVED" -gt 0 ] && OUTPUT="$OUTPUT • +${LINES_ADDED}/-${LINES_REMOVED}"

# Add rate limit if available
if [ -n "$RATE_5H" ]; then
    if [ "$RATE_5H" -ge 90 ]; then
        OUTPUT="$OUTPUT • 5h: ${YELLOW}${RATE_5H}%${RESET}"
    else
        OUTPUT="$OUTPUT • 5h: ${RATE_5H}%"
    fi
fi

# Add account if set
[ -n "$ACCT" ] && OUTPUT="$OUTPUT • $ACCT"

# TTS indicator
[ -f ~/.claude/tts-enabled ] && OUTPUT="$OUTPUT • \033[34mTTS Enabled\033[0m"

printf '%b\n' "$OUTPUT"
