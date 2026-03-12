#!/bin/bash

if [ -z "$TMUX" ]; then
  exit 0
fi

pane_active=$(tmux display-message -p -t "$TMUX_PANE" '#{&&:#{pane_active},#{window_active}}' 2>/dev/null)
frontmost=$(osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null | tr '[:upper:]' '[:lower:]')

if [[ "$pane_active" == "1" && "$frontmost" == "ghostty" ]]; then
  exit 0
fi

input=$(cat)
hook_event=$(echo "$input" | jq -r '.hook_event_name // empty')
transcript=$(echo "$input" | jq -r '.transcript_path // empty')
if [[ -n "$transcript" && -f "$transcript" ]]; then
  prompt=$(jq -r 'select(.type == "assistant") | .message.content | if type == "array" then map(select(.type == "text") | .text) | last // empty else . end' "$transcript" 2>/dev/null | grep -v '^$' | tail -1 | head -c 100)
fi

if [[ "$hook_event" == "Notification" ]]; then
  label="Needs input"
else
  label="Done"
fi
prompt="${prompt:-Task complete}"

# Use -t $TMUX_PANE to get the window where Claude is running, not the focused window
tmux_session=$(tmux display-message -p -t "$TMUX_PANE" '#S')
tmux_window=$(tmux display-message -p -t "$TMUX_PANE" '#I')
tmux_window_name=$(tmux display-message -p -t "$TMUX_PANE" '#W')

# Bell the pane so tmux highlights the window in the status bar
pane_tty=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
if [ -n "$pane_tty" ]; then
  printf '\a' > "$pane_tty"
fi

if [[ "$frontmost" != "ghostty" ]]; then
  # Not in Ghostty — use native OSC 9 for Ghostty-branded notification
  client_tty=$(tmux display-message -p '#{client_tty}' 2>/dev/null)
  if [[ -n "$client_tty" ]]; then
    printf '\e]9;Claude Code: %s: %s\a' "$label" "$prompt" > "$client_tty"
  fi
else
  # In Ghostty on a different tmux tab — OSC 9 would be suppressed, use terminal-notifier
  terminal-notifier \
    -title "Claude Code" \
    -subtitle "$tmux_window_name" \
    -message "$label: $prompt" \
    -activate com.mitchellh.ghostty \
    -execute "osascript -e 'tell application \"Ghostty\" to activate' && /opt/homebrew/bin/tmux select-window -t '$tmux_session:$tmux_window' && /opt/homebrew/bin/tmux select-pane -t '$TMUX_PANE'" \
    -group "claude-$tmux_session-$tmux_window" \
    -ignoreDnD
fi
