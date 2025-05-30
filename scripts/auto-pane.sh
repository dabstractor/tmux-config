#!/bin/bash

zoomed=$(tmux display -p "#{window_zoomed_flag}"); \

if [ "$zoomed" = "1" ]; then
    tmux resize-pane -Z
fi

# Get current pane dimensions
width=$(tmux display -p "#{pane_width}")
height=$(tmux display -p "#{pane_height}")

# Get screen dimensions
screen_width=$(tmux display -p "#{client_width}")
screen_height=$(expr $(tmux display -p "#{client_height}") - 1)

width=$(tmux display -p "#{pane_width}")
height=$(tmux display -p "#{pane_height}")

# Check if pane is fullscreen
if [ "$width" -eq "$screen_width" ] && [ "$height" -eq "$screen_height" ]; then
    tmux split-window -h -c "#{pane_current_path}"
else
    # Use aspect ratio to determine split direction
    if [ "$width" -gt $((height * 5)) ]; then
        tmux split-window -h -c "#{pane_current_path}"
    else
        tmux split-window -v -c "#{pane_current_path}"
    fi
fi

if [ "$zoomed" = "1" ]; then
    tmux resize-pane -Z
fi
