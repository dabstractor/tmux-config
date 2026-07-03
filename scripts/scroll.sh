#!/usr/bin/env bash
# ~/.config/tmux/scripts/scroll.sh
#
# Picker detector for the rotary-encoder Up binding. Exits 0 if an inline
# interactive picker (fzf, sk, gum, fzy, peco) is running anywhere under the
# given pane pid; exits 1 otherwise. The binding passes the key through when a
# picker is active, otherwise enters copy-mode (scrollback).
#
# Why a script: fzf in --height / Ctrl-R / tab mode runs nested under a subshell,
# so tmux reports the pane as the shell (cmd=zsh, alt=0) -- indistinguishable
# from idle. We detect it by walking the pane's process tree.
#
# Why /proc/<pid>/task/<pid>/children instead of pstree: the kernel maintains
# that file, so we walk only this pane's subtree instead of scanning all of
# /proc -- ~5ms vs ~200ms for pstree on a busy system.
#
# Usage: scroll.sh <pane_pid>
# Add more pickers to the `case` below.
pid="${1:?}"
stack="$pid"
while [ -n "$stack" ]; do
    node="${stack%% *}"; stack="${stack#"$node"}"; stack="${stack# }"
    case "$(cat /proc/"$node"/comm 2>/dev/null)" in
        fzf|sk|gum|fzy|peco) exit 0 ;;
    esac
    children="$(cat /proc/"$node"/task/"$node"/children 2>/dev/null)"
    [ -n "$children" ] && stack="$children $stack"
done
exit 1
