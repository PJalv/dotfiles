#!/bin/bash

# Toggle script for voice_typer
# This script communicates with the running voice_typer process

SOCKET_PATH="/tmp/voice_typer.sock"
STATUS_FILE="/tmp/voice_typer_status"
PIDFILE="/tmp/voice_typer.pid"

# Function to start the voice_typer process if it's not running
ensure_voice_typer_running() {
  # Check if process is running
  if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if ps -p "$PID" > /dev/null; then
      # Process is running, all good
      return 0
    else
      # Stale PID file, remove it
      rm "$PIDFILE"
    fi
  fi
  
  # Start the process
  echo "Starting voice typer process..."
  python3 "$(dirname "$0")/main.py" &
  echo $! > "$PIDFILE"
  
  # Wait a moment for the socket to be created
  sleep 1
}

# Function to toggle voice typing via socket
toggle_voice_typing() {
  if [ -S "$SOCKET_PATH" ]; then
    # Send TOGGLE command to the socket
    echo -n "TOGGLE" | nc -U "$SOCKET_PATH"
    echo "Toggled voice typing state."
    get_status
  else
    echo "Error: Voice typer socket not found. Is the service running?"
    exit 1
  fi
}

# Function to get current status
get_status() {
  if [ -f "$STATUS_FILE" ]; then
    cat "$STATUS_FILE"
  else
    echo "UNKNOWN"
  fi
}

# Main executionhhh
# ensure_voice_typer_running
toggle_voice_typing

