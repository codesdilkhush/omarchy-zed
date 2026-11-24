#!/bin/bash
set -euo pipefail

running=false
if pgrep -f "zed-editor|/usr/bin/zeditor" >/dev/null 2>&1; then
  running=true
fi

theme_name="Unknown"
if [[ -f "$HOME/.local/state/omarchy/current/theme.name" ]]; then
  theme_name=$(cat "$HOME/.local/state/omarchy/current/theme.name" 2>/dev/null || echo "Unknown")
elif [[ -f "$HOME/.config/omarchy/current/theme.name" ]]; then
  theme_name=$(cat "$HOME/.config/omarchy/current/theme.name" 2>/dev/null || echo "Unknown")
fi

zed_theme="Unknown"
settings_file="$HOME/.config/zed/settings.json"
if [[ -f "$settings_file" ]] && command -v jq >/dev/null 2>&1; then
  zed_theme=$(jq -r 'if (.theme | type) == "string" then .theme elif (.theme | type) == "object" then (.theme.dark // .theme.mode // "Custom") else "Unknown" end' "$settings_file" 2>/dev/null || echo "Unknown")
fi

theme_synced=false
if [[ "${zed_theme,,}" == "omazed" ]]; then
  theme_synced=true
fi

printf '{"running":%s,"theme_name":"%s","zed_theme":"%s","theme_synced":%s}\n' \
  "$running" "$theme_name" "$zed_theme" "$theme_synced"
