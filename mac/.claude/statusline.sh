#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PERCENT_USED=$(echo "$input" | jq -r '.context_window.used_percentage // 0')

# Remove home path from DIR
DIR="${DIR#$HOME/}"

# Keep only the first word of MODEL (removes version) and lowercase it
MODEL=$(echo "${MODEL%% *}" | tr '[:upper:]' '[:lower:]')

# Git branch
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    [ -n "$BRANCH" ] && GIT_BRANCH=" • $BRANCH"
fi

echo "$DIR$GIT_BRANCH • $MODEL • ${PERCENT_USED} %"
