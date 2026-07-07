#!/usr/bin/env bash
# Compose the two ORTHOGONAL style dimensions and apply them live:
#
#   THEME  = colors + border character  (tubular built-in name, or a path to
#            a .theme file)                       state: @tubular_theme
#   LAYOUT = status line content        (layouts/<name>.tmux)
#                                                 state: @tubular_layout_current
#
# Apply order (the invariant that makes the dimensions independent):
#   1. wipe    — all tubular/foreign-theme options AND the native content
#                options, so nothing ghosts between combinations
#   2. theme   — set @tubular_theme and run tubular ONCE, purely to resolve
#                the palette into the @_tubular_* options. Layouts read these
#                (via `set -gF "#{@_tubular_...}"` or show-option) to paint
#                their foreign plugins in the live theme's colors.
#   3. layout  — sets content only (may run widget/foreign plugins itself)
#   4. theme again + tubular LAST — re-assert the theme over anything the
#                layout dragged in (00-custom sources tubular.conf, which
#                sets one) and let tubular re-take every *-style. Tubular
#                owns the color; the layout keeps the text.
#
# Usage: tubular-style-apply.sh <layout|-> <theme|->   ("-" = keep current)
# Called by tubular-layout-cycle.sh / tubular-theme-cycle.sh; safe to run
# directly to jump to any combination.

TMUX_DIR="$HOME/.config/tmux"
PLUGIN="$TMUX_DIR/plugins/tubular-tmux/tubular.tmux"
LAYOUTS_DIR="$TMUX_DIR/layouts"

layout="${1:--}"; theme="${2:--}"
if [ "$layout" = "-" ]; then
  layout="$(tmux show-option -gqv @tubular_layout_current)"
  [ -n "$layout" ] || layout="00-custom"
fi
if [ "$theme" = "-" ]; then
  theme="$(tmux show-option -gqv @tubular_theme)"
  [ -n "$theme" ] || theme="tubular"
fi
[ -f "$LAYOUTS_DIR/$layout.tmux" ] || { echo "unknown layout: $layout" >&2; exit 1; }

# 1. wipe: tubular state, foreign-theme state (catppuccin bakes @thm_* /
# @_ctp_* with -F and sets them -o only-if-unset, so they'd ghost forever),
# widget options, then the native content options back to tmux defaults so a
# layout that doesn't set a slot shows the default, not leftovers.
for opt in $(tmux show-options -g 2>/dev/null \
    | awk '$1 ~ /^(@_?tubular|@thm_|@_ctp|@catppuccin|@prefix_highlight)/ {print $1}'); do
  tmux set-option -gu "$opt" 2>/dev/null
done
for opt in status-left status-right status-left-length status-right-length \
           window-status-format window-status-current-format window-status-separator; do
  tmux set-option -gu "$opt" 2>/dev/null
done

# base: personal settings neither dimension owns. Layouts may override
# status-position; themes may not.
tmux set-option -g @tubular_prefix_key "C-Space"
tmux set-option -g status-position top

set_theme_options() {
  tmux set-option -g @tubular_theme "$theme"
  if [ "$theme" = "tubular" ]; then
    tmux set-option -g @tubular_pane_bg "active"  # my transparency setup
  else
    tmux set-option -g @tubular_pane_bg "on"      # full paint: the theme owns the terminal
  fi
}

# 2. resolve the theme palette into @_tubular_* so the layout can read it
set_theme_options
"$PLUGIN"

# 3. layout (content; foreign plugins may consume the resolved palette)
tmux source-file "$LAYOUTS_DIR/$layout.tmux"

# 4. theme again (beats anything the layout dragged in) + tubular last
set_theme_options
"$PLUGIN"

tmux set-option -g @tubular_layout_current "$layout"
