#!/bin/bash

# Read input character by character
while IFS= read -r -n1 char; do
  # Build up the command string
  buffer="${buffer}${char}"
  
  # Check for our navigation commands
  if [[ "$buffer" == *"§§§PREV§§§"* ]]; then
    tmux select-window -p
    buffer=""
  elif [[ "$buffer" == *"§§§NEXT§§§"* ]]; then
    tmux select-window -n  
    buffer=""
  fi
  
  # Prevent buffer from growing too large
  if [[ ${#buffer} -gt 20 ]]; then
    buffer=""
  fi
done
