#!/bin/bash

# Function to detect and extract SSH connection details
get_ssh_command() {
    local current_command=$(tmux display -p "#{pane_current_command}")
    local pane_pid=$(tmux display -p "#{pane_pid}")

    # Check if current command is ssh
    if [[ "$current_command" == "ssh" ]]; then
        # Get the full command line from the process
        local full_command=$(ps -p "$pane_pid" -o args= 2>/dev/null | head -1)
        if [[ "$full_command" == ssh* ]]; then
            echo "$full_command"
            return 0
        fi
    fi

    # Also check child processes in case ssh is running in a shell
    local ssh_process=$(pgrep -P "$pane_pid" ssh 2>/dev/null | head -1)
    if [[ -n "$ssh_process" ]]; then
        local ssh_command=$(ps -p "$ssh_process" -o args= 2>/dev/null | head -1)
        if [[ "$ssh_command" == ssh* ]]; then
            echo "$ssh_command"
            return 0
        fi
    fi

    return 1
}

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

# Check for SSH session and get command if present
ssh_command=$(get_ssh_command)
ssh_detected=$?

# Check if pane is fullscreen
if [ "$width" -eq "$screen_width" ] && [ "$height" -eq "$screen_height" ]; then
    tmux split-window -h -c "#{pane_current_path}"
    if [ "$ssh_detected" -eq 0 ]; then
        tmux send-keys "$ssh_command" Enter
    fi
else
    # Use aspect ratio to determine split direction
    if [ "$width" -gt $((height * 5)) ]; then
        tmux split-window -h -c "#{pane_current_path}"
        if [ "$ssh_detected" -eq 0 ]; then
            tmux send-keys "$ssh_command" Enter
        fi
    else
        tmux split-window -v -c "#{pane_current_path}"
        if [ "$ssh_detected" -eq 0 ]; then
            tmux send-keys "$ssh_command" Enter
        fi
    fi
fi

if [ "$zoomed" = "1" ]; then
    tmux resize-pane -Z
fi
