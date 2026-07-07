# Layout 01 — Minimal / plain native (the baseline).
# No inline #[fg=]/#[bg=] anywhere. Every character inherits the segment
# *-style, which tubular pins to the live mode color — so the active theme
# colors 100% of this layout, and it lights up fully in every mode.
set -g status-left    " #S · #W "
set -g status-right   " %H:%M · %d-%b "
set -g window-status-format          " #I:#W "
set -g window-status-current-format  " #I:#W (active) "
set -g window-status-separator "  "
