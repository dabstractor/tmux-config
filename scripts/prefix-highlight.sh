#!/bin/bash
# Optimized prefix highlight with batched operations and state caching

# Get color configurations (tmux show-option doesn't support batching)
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

# Check if this is a special mode activation
MODE="$1"

if [ "$MODE" = "activate" ]; then
    # Prefix activation: set colors FIRST, then switch-client to avoid lag
    tmux set -g status-bg "$HIGHLIGHT_COLOR" \; \
         set -g pane-active-border-style "fg=$HIGHLIGHT_COLOR,bg=$HIGHLIGHT_COLOR" \; \
         set -g window-active-style "$WINDOW_ACTIVE_STYLE_HIGHLIGHT" \; \
         set -g @active_pane_in_mode "0" \; \
         set -g @current_display_mode "prefix" \; \
         switch-client -T prefix \; \
         refresh-client -S

    # Start polling
    ALREADY_POLLING=$(tmux show-option -gv @prefix_polling 2>/dev/null)
    if [ "$ALREADY_POLLING" != "1" ]; then
        tmux set -g @prefix_polling "1"
        tmux run-shell -b "sleep 0.01 && $0 poll 1"
    fi
    exit 0
fi

# Check if this is a poll continuation
POLLING="$MODE"
POLL_COUNT="${2:-0}"

# Batch all status checks into single tmux call - MASSIVE performance improvement
# Format: client_prefix|pane_in_mode|window_zoomed_flag
read -r CLIENT_PREFIX PANE_IN_MODE WINDOW_ZOOMED <<< "$(tmux display-message -p '#{client_prefix}|#{pane_in_mode}|#{window_zoomed_flag}' 2>/dev/null | tr '|' ' ')"

# Determine current mode (priority: prefix > copy > zoom > normal)
if [ "$CLIENT_PREFIX" = "1" ]; then
    NEW_MODE="prefix"
    STATUS_BG="$HIGHLIGHT_COLOR"
    PANE_COLOR="$HIGHLIGHT_COLOR"
    WINDOW_STYLE="$WINDOW_ACTIVE_STYLE_HIGHLIGHT"
    ACTIVE_IN_MODE="0"
    ACTIVE_ZOOMED="$WINDOW_ZOOMED"
elif [ "$PANE_IN_MODE" = "1" ]; then
    NEW_MODE="copy"
    STATUS_BG="$COPY_MODE_COLOR"
    PANE_COLOR="$COPY_MODE_PANE_COLOR"
    WINDOW_STYLE="$WINDOW_ACTIVE_STYLE_COPY"
    ACTIVE_IN_MODE="1"
    ACTIVE_ZOOMED="$WINDOW_ZOOMED"
elif [ "$WINDOW_ZOOMED" = "1" ]; then
    NEW_MODE="zoom"
    STATUS_BG="$ZOOM_MODE_COLOR"
    PANE_COLOR="$ZOOM_MODE_PANE_COLOR"
    WINDOW_STYLE="$WINDOW_ACTIVE_STYLE_ZOOM"
    ACTIVE_IN_MODE="0"
    ACTIVE_ZOOMED="1"
else
    NEW_MODE="normal"
    STATUS_BG="$NORMAL_COLOR"
    PANE_COLOR="$NORMAL_PANE_COLOR"
    WINDOW_STYLE="$WINDOW_ACTIVE_STYLE_NORMAL"
    ACTIVE_IN_MODE="0"
    ACTIVE_ZOOMED="0"
fi

# State caching: only update if mode changed
CURRENT_MODE=$(tmux show-option -gv @current_display_mode 2>/dev/null)

if [ "$NEW_MODE" != "$CURRENT_MODE" ]; then
    # Batch ALL tmux set commands into single call - eliminates multiple process spawns
    tmux set -g status-bg "$STATUS_BG" \; \
         set -g pane-active-border-style "fg=$PANE_COLOR,bg=$PANE_COLOR" \; \
         set -g window-active-style "$WINDOW_STYLE" \; \
         set -g @active_pane_in_mode "$ACTIVE_IN_MODE" \; \
         set -g @active_window_zoomed "$ACTIVE_ZOOMED" \; \
         set -g @current_display_mode "$NEW_MODE" \; \
         refresh-client -S
fi

# Adaptive polling: faster initially, slows down over time
if [ "$NEW_MODE" = "prefix" ]; then
    # Determine poll interval based on iteration count
    if [ "$POLL_COUNT" -lt 3 ]; then
        INTERVAL="0.01"  # 100 Hz for instant response
    elif [ "$POLL_COUNT" -lt 10 ]; then
        INTERVAL="0.05"  # 20 Hz after initial burst
    else
        INTERVAL="0.1"   # 10 Hz for sustained prefix hold
    fi

    # Only start polling if not already polling
    if [ "$POLLING" = "poll" ]; then
        # Continue the polling loop with incremented counter
        tmux run-shell -b "sleep $INTERVAL && $0 poll $((POLL_COUNT + 1))"
    else
        # Check if already polling (atomic check)
        ALREADY_POLLING=$(tmux show-option -gv @prefix_polling 2>/dev/null)
        if [ "$ALREADY_POLLING" != "1" ]; then
            tmux set -g @prefix_polling "1"
            tmux run-shell -b "sleep 0.01 && $0 poll 1"
        fi
    fi
else
    # Clear polling flag when exiting prefix mode
    if [ "$CURRENT_MODE" = "prefix" ]; then
        tmux set -g @prefix_polling "0"
    fi
fi

exit 0
