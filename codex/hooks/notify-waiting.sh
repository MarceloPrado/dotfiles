#!/bin/bash
# Notify when Codex CLI finishes a turn, with tmux session info.
# Clicking the notification activates the correct tmux window.
# Skips if user is already focused on the pane.
#
# Codex passes JSON as argv[1] with fields:
#   type, thread-id, last-assistant-message, input-messages, cwd

# Only notify if we're inside tmux
if [ -z "$TMUX" ]; then
  exit 0
fi

# Only handle agent-turn-complete
event_type=$(echo "$1" | jq -r '.type // empty' 2>/dev/null)
if [ "$event_type" != "agent-turn-complete" ]; then
  exit 0
fi

# Skip if pane is active and Ghostty is frontmost
pane_active=$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{pane_active},#{window_active}}' 2>/dev/null)
frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null)

if [[ "$pane_active" == "1" && "$frontmost" == "Ghostty" ]]; then
  exit 0
fi

# Extract context from notification payload
message=$(echo "$1" | jq -r '.["last-assistant-message"] // empty' 2>/dev/null | head -c 100)
thread_id=$(echo "$1" | jq -r '.["thread-id"] // empty' 2>/dev/null)

TMUX_SESSION=$(tmux display-message -p '#S')
TMUX_WINDOW=$(tmux display-message -p '#I')
TMUX_WINDOW_NAME=$(tmux display-message -p '#W')

message="${message:-Turn complete}"

# Send bell to the pane's tty so tmux highlights the window in the status bar
pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
if [ -n "$pane_tty" ]; then
  printf '\a' > "$pane_tty"
fi

terminal-notifier \
  -title "Codex" \
  -subtitle "$TMUX_SESSION — $TMUX_WINDOW_NAME" \
  -message "$message" \
  -execute "tmux select-window -t '$TMUX_SESSION:$TMUX_WINDOW'; open -b com.mitchellh.ghostty" \
  -group "codex-${thread_id:-$TMUX_SESSION-$TMUX_WINDOW}" \
  -ignoreDnD

exit 0
