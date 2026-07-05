# Layout 1 — Minimal / plain native (the baseline).
# No inline #[fg=]/#[bg=] anywhere. Every character inherits the segment
# *-style, which tubular pins to the live mode color. This is the BEST-CASE
# compatibility: tubular's mode coloring fully wraps the foreign text.
source-file ~/.config/tmux/layouts/_tubular-colors.tmux
run-shell  ~/.config/tmux/plugins/tubular-tmux/tubular.tmux

set -g status-left    " #S · #W "
set -g status-right   " %H:%M · %d-%b "
set -g window-status-format          " #I:#W "
set -g window-status-current-format  " #I:#W (active) "
set -g window-status-separator "  "
