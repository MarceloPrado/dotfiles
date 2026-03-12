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
frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null | tr '[:upper:]' '[:lower:]')

if [[ "$pane_active" == "1" && "$frontmost" == "ghostty" ]]; then
  exit 0
fi

# Extract context from notification payload
message=$(echo "$1" | jq -r '.["last-assistant-message"] // empty' 2>/dev/null | head -c 100)
thread_id=$(echo "$1" | jq -r '.["thread-id"] // empty' 2>/dev/null)

# Use -t $TMUX_PANE to get the window where Codex is running, not the focused window
TMUX_SESSION=$(tmux display-message -p -t "$TMUX_PANE" '#S')
TMUX_WINDOW=$(tmux display-message -p -t "$TMUX_PANE" '#I')
TMUX_WINDOW_NAME=$(tmux display-message -p -t "$TMUX_PANE" '#W')

message="${message:-Turn complete}"

# Send bell to the pane's tty so tmux highlights the window in the status bar
pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
if [ -n "$pane_tty" ]; then
  printf '\a' > "$pane_tty"
fi

if [[ "$frontmost" != "ghostty" ]]; then
  # Not in Ghostty — use native OSC 9 for Ghostty-branded notification
  client_tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
  if [[ -n "$client_tty" ]]; then
    printf '\e]9;Codex: %s\a' "$message" > "$client_tty"
  fi
else
  # In Ghostty on a different tmux window — use terminal-notifier
  terminal-notifier \
    -title "Codex" \
    -subtitle "$TMUX_WINDOW_NAME" \
    -message "$message" \
    -activate com.mitchellh.ghostty \
    -execute "osascript -e 'tell application \"Ghostty\" to activate' && /opt/homebrew/bin/tmux select-window -t '$TMUX_SESSION:$TMUX_WINDOW' && /opt/homebrew/bin/tmux select-pane -t '$TMUX_PANE'" \
    -group "codex-${thread_id:-$TMUX_SESSION-$TMUX_WINDOW}" \
    -ignoreDnD
fi
