#!/bin/bash

# Script to continuously monitor voice typer status and output JSON for Waybar
# Usage: Add this to your Waybar config as:
# "custom/voice-typer": {
#     "format": "{}",
#     "return-type": "json",
#     "exec": "/path/to/voice_typer_waybar.sh",
#     "on-click": "bash /home/pjalv/projects/voice_typer/toggle_voice_typer.sh"
# }

STATUS_FILE="/tmp/voice_typer_status"
SOCKET_PATH="/tmp/voice_typer.sock"

# Function to get current status
get_status() {
  if [ -f "$STATUS_FILE" ]; then
    cat "$STATUS_FILE"
  else
    echo "inactive"
  fi
}

# Function to output JSON for Waybar
output_json() {
  local status=$(get_status)
  local icon="🎤"
  local tooltip="Voice Typer"
  
  # Customize icon based on status
  if [ "$status" = "active" ]; then
    tooltip="ACTIVE"
  elif [ "$status" = "inactive" ]; then
    tooltip=""
    icon="🔇"
  else
    tooltip=""
    icon="🔇"
  fi
  
  # Output JSON
  echo "{\"text\":\"$icon: $tooltip\", \"tooltip\":\"$tooltip\", \"class\":\"$status\", \"alt\":\"voice-typer\"}"
}

# Initial output
output_json

# Set up inotify to watch for changes to the status file
if command -v inotifywait >/dev/null 2>&1; then
  # Use inotify if available (more efficient)
  while true; do
    inotifywait -q -e modify "$STATUS_FILE" >/dev/null 2>&1
    output_json
  done
else
  # Fallback to polling if inotify is not available
  while true; do
    sleep 0.5
    output_json
  done
fi
