#!/usr/bin/env bash
# Toggle the tubular palette between the custom config (tubular.conf) and the
# editable default config (tubular-default.conf), live, without restarting the
# tmux server. State is tracked in @tubular_palette_mode.

TMUX_DIR="$HOME/.config/tmux"
PLUGIN="$TMUX_DIR/plugins/tubular-tmux/tubular.tmux"

current=$(tmux show-option -gqv @tubular_palette_mode)
if [ "$current" = "default" ]; then
    next="custom"
    conf="$TMUX_DIR/tubular.conf"
else
    next="default"
    conf="$TMUX_DIR/tubular-default.conf"
fi

# Wipe every tubular option first, so any value the target file omits (or that
# you comment out) reverts to the plugin default instead of ghosting from
# server memory.
for opt in $(tmux show-options -g | awk '$1 ~ /^@_?tubular/ {print $1}'); do
    tmux set-option -gu "$opt"
done

# Apply the target palette, then re-run the plugin to restyle everything.
tmux source-file "$conf"
"$PLUGIN"

tmux set-option -g @tubular_palette_mode "$next"
tmux display-message "tubular palette → $next"
