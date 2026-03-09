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

# Extract last user prompt from transcript for context
input=$(cat)
transcript=$(echo "$input" | jq -r '.transcript_path' 2>/dev/null)
prompt=""
if [ -n "$transcript" ] && [ -f "$transcript" ]; then
  prompt=$(jq -r 'select(.type == "user") | .message.content | if type == "array" then map(select(.type == "text") | .text) | first // empty else . end' "$transcript" 2>/dev/null | tail -1 | head -c 100)
fi

TMUX_SESSION=$(tmux display-message -p '#S')
TMUX_WINDOW=$(tmux display-message -p '#I')
TMUX_WINDOW_NAME=$(tmux display-message -p '#W')

message="${prompt:-Waiting for your input}"

# Send bell to the pane so tmux highlights the window in the status bar
tmux run-shell -t "$TMUX_PANE" "printf '\a'" 2>/dev/null

terminal-notifier \
  -title "Claude Code" \
  -subtitle "$TMUX_SESSION — $TMUX_WINDOW_NAME" \
  -message "$message" \
  -execute "tmux select-window -t '$TMUX_SESSION:$TMUX_WINDOW'" \
  -group "claude-$TMUX_SESSION-$TMUX_WINDOW" \
  -ignoreDnD

exit 0
