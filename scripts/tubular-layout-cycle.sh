#!/usr/bin/env bash
# Cycle the LAYOUT dimension (status line content) of the tubular style
# gallery. The current THEME (colors) is preserved — the two dimensions are
# orthogonal; tubular-style-apply.sh composes them.
#
# Each layouts/NN-name.tmux sets CONTENT only (it may run widget/foreign
# statusline plugins itself); colors always come from the active theme, with
# tubular running last. Adding a new NN-name.tmux just works.
#
# Usage:
#   tubular-layout-cycle.sh            # advance to the next layout (default)
#   tubular-layout-cycle.sh prev       # go back one
#   tubular-layout-cycle.sh <name>     # jump to a layout by basename (no .tmux)
#   tubular-layout-cycle.sh list       # print the gallery + current selection
#
# Bound to <prefix>+Ctrl+/. State lives in @tubular_layout_current.

TMUX_DIR="$HOME/.config/tmux"
APPLY="$TMUX_DIR/scripts/tubular-style-apply.sh"
LAYOUTS_DIR="$TMUX_DIR/layouts"

mapfile -t files < <(find "$LAYOUTS_DIR" -maxdepth 1 -type f -name '*.tmux' \
                       ! -name '_*' | sort)
names=()
for f in "${files[@]}"; do b="${f##*/}"; names+=("${b%.tmux}"); done
n=${#names[@]}
[ "$n" -eq 0 ] && { echo "no layouts in $LAYOUTS_DIR" >&2; exit 1; }

cur="$(tmux show-option -gqv @tubular_layout_current)"; [ -n "$cur" ] || cur="${names[0]}"
idx=0
for i in "${!names[@]}"; do [ "${names[$i]}" = "$cur" ] && idx=$i; done

apply() {
  "$APPLY" "${names[$1]}" -
  tmux display-message -d 1000 "layout → ${names[$1]}"
}

case "${1:-next}" in
  list)
    for i in "${!names[@]}"; do
      mark=" "; [ "$i" = "$idx" ] && mark=">"
      printf '%s %2d  %-24s %s\n' "$mark" "$i" "${names[$i]}" "${files[$i]}"
    done
    ;;
  next) apply $(( (idx + 1) % n )) ;;
  prev) apply $(( (idx - 1 + n) % n )) ;;
  *)
    for i in "${!names[@]}"; do
      if [ "${names[$i]}" = "$1" ] || [ "$i" = "$1" ]; then apply "$i"; exit 0; fi
    done
    echo "unknown layout: $1 (have: ${names[*]})" >&2
    exit 1
    ;;
esac
