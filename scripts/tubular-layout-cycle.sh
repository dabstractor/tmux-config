#!/usr/bin/env bash
# Cycle tubular through a gallery of popular STATUSLINE LAYOUTS (content
# plugins/styles), live, without restarting the tmux server. This tests
# tubular's compatibility claim — "tubular owns color, you own text" — by
# pairing tubular (colors-only) with foreign statusline content and letting
# you see how much of the mode coloring survives.
#
# Each layouts/*.tmux is self-contained: it loads tubular in colors-only mode,
# then applies the foreign statusline LAST (the realistic TPM-loads-last order).
#
# Usage:
#   tubular-layout-cycle.sh            # advance to the next layout (default)
#   tubular-layout-cycle.sh <name>     # jump to a layout by basename (no .tmux)
#   tubular-layout-cycle.sh prev       # go back one
#   tubular-layout-cycle.sh list       # print the gallery + current selection
#
# Bound to <prefix>+/. The older 2-way palette toggle (<prefix>+Ctrl+t) is
# untouched. State lives in @tubular_layout_index (0-based).

TMUX_DIR="$HOME/.config/tmux"
LAYOUTS_DIR="$TMUX_DIR/layouts"

# Ordered gallery, derived from the filenames so adding a new NN-name.tmux
# just works. Sorted lexically → keep the NN- numeric prefixes.
mapfile -t files < <(find "$LAYOUTS_DIR" -maxdepth 1 -type f -name '*.tmux' \
                       ! -name '_*' | sort)
n=${#files[@]}
[ "$n" -eq 0 ] && { echo "no layouts in $LAYOUTS_DIR" >&2; exit 1; }

label_of() { b="$(basename "${files[$1]}")"; printf '%s' "${b%.tmux}"; }

idx=$(tmux show-option -gqv @tubular_layout_index 2>/dev/null)
[[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -lt "$n" ] || idx=0

apply() {
  local i="$1" target="${files[$1]}"
  # Wipe every tubular option first so values from the previous layout don't
  # ghost into the next one (same trick the palette toggle uses).
  for opt in $(tmux show-options -g 2>/dev/null | awk '$1 ~ /^@_?tubular/ {print $1}'); do
    tmux set-option -gu "$opt" 2>/dev/null
  done
  # Reset the bar to the top by default each cycle; a layout that wants the
  # bottom sets status-position itself after this line runs.
  tmux set-option -g status-position top
  # The layout file sources tubular + applies the foreign statusline itself.
  tmux source-file "$target"
  tmux set-option -g @tubular_layout_index "$i"
  tmux display-message "tubular layout → $(label_of "$i")"
}

case "${1:-next}" in
  list)
    for i in "${!files[@]}"; do
      mark=" "; [ "$i" = "$idx" ] && mark=">"
      printf '%s %2d  %-22s  %s\n' "$mark" "$i" "$(label_of "$i")" "${files[$i]}"
    done
    ;;
  next) apply $(( (idx + 1) % n )) ;;
  prev) apply $(( (idx - 1 + n) % n )) ;;
  *)
    for i in "${!files[@]}"; do
      if [ "$(label_of "$i")" = "$1" ] || [ "$i" = "$1" ]; then apply "$i"; exit 0; fi
    done
    echo "unknown layout: $1" >&2
    echo "known:" "${files[@]##*/}" >&2
    exit 1
    ;;
esac
