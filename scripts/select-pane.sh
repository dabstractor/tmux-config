#!/bin/sh

# A script to select a new tmux pane while preserving the zoom state.

# Exit if not running inside tmux.
if [ -z "$TMUX" ]; then
    exit 0
fi

# Exit if no direction argument is provided (e.g., -L, -R, -U, -D).
if [ -z "$1" ]; then
    echo "Usage: $0 <direction_flag>" >&2
    exit 1
fi

DIRECTION=$1

# 1. Check if the *current* pane is zoomed before we move.
#    `tmux display-message -p '#{pane_zoomed}'` will print '1' if zoomed, '0' otherwise.
IS_ZOOMED=$(tmux display-message -p '#{window_zoomed_flag}')

# 2. Select the target pane in the specified direction.
tmux select-pane "$DIRECTION"

# 3. If the original pane was zoomed, zoom the new pane.
#    The `[ "$VAR" -eq 1 ]` construct is a reliable way to check for the numeric value '1'.
if [ "$IS_ZOOMED" -eq 1 ]; then
    tmux resize-pane -Z
fi
