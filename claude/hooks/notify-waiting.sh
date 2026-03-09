#!/bin/bash
# Notify when Claude Code is waiting for input, with tmux session info.
# Clicking the notification activates the correct tmux window.
# Skips if user is already focused on the pane.

# Only notify if we're inside tmux
if [ -z "$TMUX" ]; then
  exit 0
fi

# Skip if pane is active and terminal is frontmost
pane_active=$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{pane_active},#{window_active}}' 2>/dev/null)
frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)
terminal_app=$(osascript -e 'tell application "System Events" to get name of (first process whose unix id is '"$(ps -o ppid= -p $(tmux display-message -p '#{client_pid}') | tr -d ' ')"')' 2>/dev/null)

if [[ "$pane_active" == "1" && "$frontmost" == "$terminal_app" ]]; then
  exit 0
fi

# Read hook stdin and log for debugging
input=$(cat)
echo "$input" > /tmp/claude-hook-debug.json
prompt=$(echo "$input" | jq -r '.last_user_message // empty' 2>/dev/null | head -c 100)

TMUX_SESSION=$(tmux display-message -p '#S')
TMUX_WINDOW=$(tmux display-message -p '#I')
TMUX_WINDOW_NAME=$(tmux display-message -p '#W')

message="${prompt:-Waiting for your input}"

# Send bell to the pane's tty so tmux highlights the window in the status bar
pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
if [ -n "$pane_tty" ]; then
  printf '\a' > "$pane_tty"
fi

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$TMUX_SESSION — $TMUX_WINDOW_NAME" \
  -message "$message" \
  -execute "tmux select-window -t '$TMUX_SESSION:$TMUX_WINDOW'; open -b com.mitchellh.ghostty" \
  -group "claude-$TMUX_SESSION-$TMUX_WINDOW" \
  -ignoreDnD

exit 0
