#!/bin/sh

# Create a new tmux window, optionally jumping to a directory first via rupa/z.
#
# Usage: z-window.sh [query ...]
#
#   - With a query: resolve it through rupa/z (best frecency match in ~/.z),
#     open the window in that directory, and name the window after that
#     directory's basename. The typed string is a z query, NOT a literal name.
#   - With no query, or if z finds no match: open the window in the current
#     pane's directory and name it after that (same outcome as plain prefix-t).
#
# rupa/z is a shell function, so the query is resolved by sourcing z.sh in a
# throwaway zsh subshell (fast, ~15ms) and reading the resulting cwd.

Z_SH=/home/dustin/.config/znap/rupa/z/z.sh
query="$*"

cur=$(tmux display-message -p '#{pane_current_path}')
[ -z "$cur" ] && cur="$HOME"
session=$(tmux display-message -p '#{session_name}')

dir="$cur"
if [ -n "$query" ] && [ -r "$Z_SH" ]; then
    resolved=$(cd "$cur" && zsh -c '. "$1"; _z "$2" >/dev/null 2>&1; pwd' _ "$Z_SH" "$query" 2>/dev/null)
    [ -n "$resolved" ] && dir="$resolved"
fi

base=$(basename "$dir")
# Quote the directory for tmux in case it contains spaces.
tmux new-window -t "$session:" -c "$dir" -n "$base"
