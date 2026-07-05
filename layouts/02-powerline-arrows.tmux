# Layout 2 — Classic Powerline arrows (the most copy-pasted statusline style).
# Every segment paints its OWN background with #[bg=colourNNN], joined by
# U+E0B0/E0B2 arrow separators. Tubular's mode color can only show through
# in the GAPS between segments (and the empty middle) — the segment blocks
# themselves ignore tubular entirely. This is the typical "partial" case.
source-file ~/.config/tmux/layouts/_tubular-colors.tmux
run-shell  ~/.config/tmux/plugins/tubular-tmux/tubular.tmux

#  = U+E0B0 (right arrow),  = U+E0B2 (left arrow) — need a Nerd Font.
set -g status-left-length 60
set -g status-right-length 60
set -g status-left "\
#[fg=#1f1f28,bg=colour33] #S \
#[fg=colour33,bg=colour238]\
#[fg=#e0e0e0,bg=colour238] #W \
#[fg=colour238,bg=default]"

set -g status-right "\
#[fg=colour238,bg=default]\
#[fg=#e0e0e0,bg=colour238] %H:%M \
#[fg=colour238,bg=colour245]\
#[fg=#1f1f28,bg=colour245] %d-%b \
#[fg=colour245,bg=default]"

set -g window-status-format "#[fg=colour244,bg=default] #I #W "
set -g window-status-current-format "#[fg=colour235,bg=colour33] #I #W #[fg=colour33,bg=default]"
set -g window-status-separator ""
