#!/bin/bash
# get window param if available, default to current window
if [ -n "$1" ]; then
  pane_count=$(tmux display-message -p -t ":$1" "#{window_panes}")
else
  pane_count=$(tmux display-message -p "#{window_panes}")
fi

case $pane_count in
  1) echo "󰼏" ;;
  2) echo "󰼐" ;;
  3) echo "󰼑" ;;
  4) echo "󰼒" ;;
  5) echo "󰼓" ;;
  6) echo "󰼔" ;;
  7) echo "󰼕" ;;
  8) echo "󰼖" ;;
  9) echo "󰼗" ;;
  *) echo "󰼘" ;;
esac
