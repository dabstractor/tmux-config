#!/usr/bin/env bash
# Cycle the THEME dimension (colors + border character) of the tubular style
# gallery. The current LAYOUT (status line content) is preserved — the two
# dimensions are orthogonal; tubular-style-apply.sh composes them.
#
# Themes are discovered from the plugin's themes/ dir, so a dropped-in .theme
# file (or a base16 import) joins the carousel automatically. "tubular" is
# pinned first: cycling all the way around lands you back on your default.
#
# Live preview only: a config reload returns you to tubular.conf. To keep a
# theme, set @tubular_theme there.
#
# Usage:
#   tubular-theme-cycle.sh            # advance to the next theme (default)
#   tubular-theme-cycle.sh prev       # go back one
#   tubular-theme-cycle.sh <name>     # jump to a theme by name
#   tubular-theme-cycle.sh list       # print the carousel + current selection
#
# Bound to <prefix>+/. State lives in @tubular_theme.

TMUX_DIR="$HOME/.config/tmux"
APPLY="$TMUX_DIR/scripts/tubular-style-apply.sh"
THEMES_DIR="$TMUX_DIR/plugins/tubular-tmux/themes"

themes=(tubular)
for f in "$THEMES_DIR"/*.theme; do
  b="$(basename "$f" .theme)"
  [ "$b" = "tubular" ] || themes+=("$b")
done
n=${#themes[@]}

cur="$(tmux show-option -gqv @tubular_theme)"; [ -n "$cur" ] || cur="tubular"
idx=0
for i in "${!themes[@]}"; do [ "${themes[$i]}" = "$cur" ] && idx=$i; done

apply() {
  "$APPLY" - "${themes[$1]}"
  # -d 1000: flash the name for just 1s so it doesn't sit over the new theme.
  tmux display-message -d 1000 "theme → ${themes[$1]}"
}

case "${1:-next}" in
  list)
    for i in "${!themes[@]}"; do
      mark=" "; [ "$i" = "$idx" ] && mark=">"
      printf '%s %d  %s\n' "$mark" "$i" "${themes[$i]}"
    done
    ;;
  next) apply $(( (idx + 1) % n )) ;;
  prev) apply $(( (idx - 1 + n) % n )) ;;
  *)
    for i in "${!themes[@]}"; do
      if [ "${themes[$i]}" = "$1" ]; then apply "$i"; exit 0; fi
    done
    echo "unknown theme: $1 (have: ${themes[*]})" >&2
    exit 1
    ;;
esac
