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

# Zoom mode colors
ZOOM_MODE_COLOR=$(tmux show-option -gv @zoom_mode_color)
ZOOM_MODE_PANE_COLOR=$(tmux show-option -gv @zoom_mode_pane_color)
WINDOW_ACTIVE_STYLE_ZOOM=$(tmux show-option -gv @zoom_mode_window_active_style)

# Check if this is a poll continuation
POLLING="$1"

if tmux display-message -p '#{client_prefix}' 2>/dev/null | grep -q '^1$'; then
    # Prefix mode is ON (highest priority)
    tmux set -g status-bg "$HIGHLIGHT_COLOR"
    tmux set -g pane-active-border-style "fg=$HIGHLIGHT_COLOR,bg=$HIGHLIGHT_COLOR"
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_HIGHLIGHT"

    tmux set -g @active_pane_in_mode "0"
    if tmux display-message -p '#{window_zoomed_flag}' 2>/dev/null | grep -q '^1$'; then
        tmux set -g @active_window_zoomed "1"
    else
        tmux set -g @active_window_zoomed "0"
    fi

    # Only start polling if not already polling
    if [ "$POLLING" = "poll" ]; then
        # Continue the polling loop
        tmux run-shell -b "sleep 0.03 && $0 poll"
    else
        # Check if already polling
        ALREADY_POLLING=$(tmux show-option -gv @prefix_polling 2>/dev/null)
        if [ "$ALREADY_POLLING" != "1" ]; then
            tmux set -g @prefix_polling "1"
            tmux run-shell -b "sleep 0.03 && $0 poll"
        fi
    fi
elif tmux display-message -p '#{pane_in_mode}' 2>/dev/null | grep -q '^1$'; then
    # Copy mode is ON
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_COPY"
    tmux set -g pane-active-border-style "fg=$COPY_MODE_PANE_COLOR,bg=$COPY_MODE_PANE_COLOR"
    tmux set -g status-bg "$COPY_MODE_COLOR"

    tmux set -g @active_pane_in_mode "1"
    if tmux display-message -p '#{window_zoomed_flag}' 2>/dev/null | grep -q '^1$'; then
        tmux set -g @active_window_zoomed "1"
    else
        tmux set -g @active_window_zoomed "0"
    fi
elif tmux display-message -p '#{window_zoomed_flag}' 2>/dev/null | grep -q '^1$'; then
    # Zoom mode is ON
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_ZOOM"
    tmux set -g pane-active-border-style "fg=$ZOOM_MODE_PANE_COLOR,bg=$ZOOM_MODE_PANE_COLOR"
    tmux set -g status-bg "$ZOOM_MODE_COLOR"

    tmux set -g @active_pane_in_mode "0"
    tmux set -g @active_window_zoomed "1"
else
    # Normal mode
    tmux set -g window-active-style "$WINDOW_ACTIVE_STYLE_NORMAL"
    tmux set -g pane-active-border-style "fg=$NORMAL_PANE_COLOR,bg=$NORMAL_PANE_COLOR"
    tmux set -g status-bg $NORMAL_COLOR

    tmux set -g @active_pane_in_mode "0"
    tmux set -g @active_window_zoomed "0"

    # Clear polling flag when exiting prefix mode
    tmux set -g @prefix_polling "0"
fi
