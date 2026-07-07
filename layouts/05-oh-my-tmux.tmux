# Layout 05 — oh-my-tmux / gpakosz-style segments (the most-starred tmux
# config), expressed with tubular {{token}} shortcuts: selective bg blocks
# joined by Powerline arrows, path + clock on the right. Because the blocks
# use theme tokens instead of hardcoded hex, the whole layout re-colors with
# the active THEME while the arrows blend into the live mode color.
#  = U+E0B0,  = U+E0B2 — need a Nerd Font.
set -g status-left-length 80
set -g status-right-length 80

# Left: a session block on the copy accent, arrow into the mode-colored bar.
set -g @tubular_status_left_text "#[fg={{bg}},bg={{copy}}] #S #[fg={{copy}},bg={{mode_bg}}] "

# Right: a path block + clock block with their own bg, arrows between.
set -g @tubular_status_right_text "#[fg={{bg_min}},bg={{mode_bg}}]#[fg={{fg}},bg={{bg_min}}] #{b:pane_current_path} #[fg={{neutral_hidden}},bg={{bg_min}}]#[fg={{fg_focus}},bg={{neutral_hidden}}] %H:%M #[fg={{neutral_hidden}},bg={{mode_bg}}]"

# Window tabs: tubular's pill with SQUARE caps for the blocky gpakosz feel.
set -g @tubular_window_tab_text " #I #W "
set -g @tubular_tab_start ""
set -g @tubular_tab_end ""
set -g @tubular_separator " "
