#!/bin/bash
# Set prefix highlight colors

HIGHLIGHT_COLOR=$(tmux show-option -gv @prefix_highlight_color)
NORMAL_COLOR=$(tmux show-option -gv @prefix_normal_color)
NORMAL_PANE_COLOR=$(tmux show-option -gv @prefix_normal_pane_color)
WINDOW_ACTIVE_STYLE_NORMAL=$(tmux show-option -gv @prefix_window_active_style_normal)
WINDOW_ACTIVE_STYLE_HIGHLIGHT=$(tmux show-option -gv @prefix_window_active_style_highlight)

# Copy mode colors
COPY_MODE_COLOR=$(tmux show-option -gv @copy_mode_color)
COPY_MODE_PANE_COLOR=$(tmux show-option -gv @copy_mode_pane_color)
WINDOW_ACTIVE_STYLE_COPY=$(tmux show-option -gv @copy_mode_window_active_style)

if tmux display-message -p '#{client_prefix}' 2>/dev/null | grep -q '^1$'; then
    # Prefix mode is ON (highest priority)
    tmux set -g status-bg "$HIGHLIGHT_COLOR"
    tmux set -g pane-active-border-style "fg=$HIGHLIGHT_COLOR,bg=$HIGHLIGHT_COLOR"
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_HIGHLIGHT"

    # Schedule this script to run again in 30ms
    tmux run-shell -b "sleep 0.03 && $0"
elif tmux display-message -p '#{pane_in_mode}' 2>/dev/null | grep -q '^1$'; then
    # Copy mode is ON
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_COPY"
    tmux set -g pane-active-border-style "fg=$COPY_MODE_PANE_COLOR,bg=$COPY_MODE_PANE_COLOR"
    tmux set -g status-bg "$COPY_MODE_COLOR"

    tmux set -g @active_pane_in_mode "1"
    # Schedule this script to run again in 30ms
    # tmux run-shell -b "sleep 0.03 && $0"
else
    # Normal mode
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_NORMAL"
    tmux set -g pane-active-border-style "fg=$NORMAL_PANE_COLOR,bg=$NORMAL_PANE_COLOR"
    tmux set -g status-bg $NORMAL_COLOR

    tmux set -g @active_pane_in_mode "0"
fi
