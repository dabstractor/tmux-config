# Layout 02 — Classic Powerline arrows (the most copy-pasted statusline
# style), expressed with tubular {{token}} shortcuts instead of hardcoded
# colours. The segment blocks re-color with the active THEME and the joints
# blend into the live mode color — a fully theme-reactive powerline.
# Tubular manages these slots because their @tubular_*_text is set.
#  = U+E0B0 (right arrow),  = U+E0B2 (left arrow) — need a Nerd Font.
set -g status-left-length 60
set -g status-right-length 60

set -g @tubular_status_left_text "#[fg={{bg}},bg={{active}}] #S #[fg={{active}},bg={{bg_min}}]#[fg={{fg}},bg={{bg_min}}] #W #[fg={{bg_min}},bg={{mode_bg}}]"

set -g @tubular_status_right_text "#[fg={{bg_min}},bg={{mode_bg}}]#[fg={{fg}},bg={{bg_min}}] %H:%M #[fg={{active}},bg={{bg_min}}]#[fg={{bg}},bg={{active}}] %d-%b "

# Window tabs: tubular's pill with SHARP powerline caps instead of rounded.
set -g @tubular_window_tab_text " #I #W "
set -g @tubular_tab_start ""
set -g @tubular_tab_end ""
set -g @tubular_separator " "
