#!/bin/bash
# Notify when Claude Code is waiting for input, with tmux session info.
# Clicking the notification activates the correct tmux window.

# Only notify if we're inside tmux
if [ -z "$TMUX" ]; then
  exit 0
fi

TMUX_SESSION=$(tmux display-message -p '#S')
TMUX_WINDOW=$(tmux display-message -p '#I')
TMUX_WINDOW_NAME=$(tmux display-message -p '#W')

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$TMUX_SESSION — $TMUX_WINDOW_NAME" \
  -message "Waiting for your input" \
  -execute "tmux select-window -t '$TMUX_SESSION:$TMUX_WINDOW'" \
  -group "claude-$TMUX_SESSION-$TMUX_WINDOW" \
  -ignoreDnD

exit 0
