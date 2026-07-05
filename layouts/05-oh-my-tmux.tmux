# Layout 5 — oh-my-tmux / gpakosz-style segments (the most-starred tmux config).
# Representative of a popular hand-rolled config: conditional coloring driven
# by client_prefix/pane_in_mode, fg-heavy with SELECTIVE bg blocks, joined by
# Powerline arrows. Mixes inheritance (text with no bg → tubular color shows)
# and override (bg blocks → tubular hidden there). The "realistic middle" case.
source-file ~/.config/tmux/layouts/_tubular-colors.tmux
run-shell  ~/.config/tmux/plugins/tubular-tmux/tubular.tmux

#  = U+E0B0,  = U+E0B2,  = U+E0BD (slanted separator)
set -g status-left-length 80
set -g status-right-length 80

# Left: a session block whose bg flips green while prefix is held (gpakosz
# does exactly this). GOTCHA: tmux's #{?cond,a,b} splits on commas, so a branch
# can't contain #[fg=x,bg=y] (its comma would end the branch). Keep branches
# comma-free by splitting fg and bg into two conditionals. The trailing arrow
# + un-bg'd text after it inherit tubular's mode color.
set -g status-left "\
#[fg=#{?client_prefix,#1f1f28,#c7c7aa},bg=#{?client_prefix,#98bb6c,#3a3a4a}] #S \
#[fg=#{?client_prefix,#98bb6c,#3a3a4a},bg=default] "

# Right: a path block + clock block, both with their own bg, arrows between.
set -g status-right "\
#[fg=#3a3a4a,bg=default]\
#[fg=#c7c7aa,bg=#3a3a4a] #{b:pane_current_path} \
#[fg=#5a5a72,bg=#3a3a4a]\
#[fg=#1f1f28,bg=#5a5a72] %H:%M \
#[fg=#5a5a72,bg=default]"

set -g window-status-format         "#[fg=#6a6a82,bg=default] #I #W "
set -g window-status-current-format "#[fg=#1f1f28,bg=#7aa89f] #I #W #[fg=#7aa89f,bg=default]"
set -g window-status-separator ""
