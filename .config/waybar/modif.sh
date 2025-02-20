#!/bin/bash

# Define keycodes for common modifier keys
CTRL_L=37      # Left Ctrl
CTRL_R=105     # Right Ctrl
ALT_L=64       # Left Alt
ALT_R=108      # Right Alt
SHIFT_L=50     # Left Shift
SHIFT_R=62     # Right Shift
SUPER_L=133    # Left Super (Windows/Meta)
SUPER_R=134    # Right Super (Windows/Meta)

# Listen for key events from xev
xev | while read -r line; do
    # Check if Ctrl is being pressed (left or right)
    if echo "$line" | grep -q "KeyPress.*keycode $CTRL_L" || echo "$line" | grep -q "KeyPress.*keycode $CTRL_R"; then
        echo "Ctrl key pressed"
    elif echo "$line" | grep -q "KeyPress.*keycode $ALT_L" || echo "$line" | grep -q "KeyPress.*keycode $ALT_R"; then
        echo "Alt key pressed"
    elif echo "$line" | grep -q "KeyPress.*keycode $SHIFT_L" || echo "$line" | grep -q "KeyPress.*keycode $SHIFT_R"; then
        echo "Shift key pressed"
    elif echo "$line" | grep -q "KeyPress.*keycode $SUPER_L" || echo "$line" | grep -q "KeyPress.*keycode $SUPER_R"; then
        echo "Super key pressed"
    fi
    
    # Check for key release events to stop printing the key
    if echo "$line" | grep -q "KeyRelease.*keycode $CTRL_L" || echo "$line" | grep -q "KeyRelease.*keycode $CTRL_R"; then
        echo "Ctrl key released"
    elif echo "$line" | grep -q "KeyRelease.*keycode $ALT_L" || echo "$line" | grep -q "KeyRelease.*keycode $ALT_R"; then
        echo "Alt key released"
    elif echo "$line" | grep -q "KeyRelease.*keycode $SHIFT_L" || echo "$line" | grep -q "KeyRelease.*keycode $SHIFT_R"; then
        echo "Shift key released"
    elif echo "$line" | grep -q "KeyRelease.*keycode $SUPER_L" || echo "$line" | grep -q "KeyRelease.*keycode $SUPER_R"; then
        echo "Super key released"
    fi
done

