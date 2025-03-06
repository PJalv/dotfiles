#!/bin/sh

# Create temporary directory for voice typing
VOICE_TYPING_DIR="/tmp/voice_typing_dir"

# Create directory if it doesn't exist
mkdir -p "$VOICE_TYPING_DIR"

# Copy required files
cp "$HOME/dotfiles/.config/waybar/shell.nix" "$VOICE_TYPING_DIR/"
cp "$HOME/dotfiles/.config/waybar/main.py" "$VOICE_TYPING_DIR/"

# Change to the temporary directory
cd "$VOICE_TYPING_DIR"

# Run nix-shell
exec nix-shell --run "uv run python main.py"

