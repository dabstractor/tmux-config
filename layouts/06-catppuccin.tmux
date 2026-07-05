# Layout 6 — catppuccin/tmux (a full theme PLUGIN, the "color fight" case).
# Cloned to plugins/catppuccin-tmux/. This plugin sources its own options +
# status format file, setting BOTH colors and content across every status
# option — i.e. it disputes tubular's core claim ("tubular owns color").
# Whichever runs LAST wins on each option. Here catppuccin runs last, so its
# colors win and tubular's mode coloring is fully overridden. (Reverse the
# run-shell order in this file to see tubular win instead.) Demonstrates the
# incompatibility of pairing two "I own the whole bar" plugins.
source-file ~/.config/tmux/layouts/_tubular-colors.tmux
run-shell  ~/.config/tmux/plugins/tubular-tmux/tubular.tmux

set -g @catppuccin_flavour "mocha"        # mocha | latte | frappe | macchiato
set -g @catppuccin_window_status_style "rounded"
run-shell ~/.config/tmux/plugins/catppuccin-tmux/catppuccin.tmux
