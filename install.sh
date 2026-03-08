#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES"

# --- Neovim ---
echo "-> Neovim"
mkdir -p ~/.config/nvim
for f in "$DOTFILES"/nvim/*; do
  name=$(basename "$f")
  ln -sf "$f" ~/.config/nvim/"$name"
done

# --- tmux ---
echo "-> tmux"
mkdir -p ~/.config/tmux/plugins/catppuccin
ln -sf "$DOTFILES/tmux/tmux.conf" ~/.config/tmux/tmux.conf

# Install catppuccin theme if not present
if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]; then
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
fi

# --- Claude Code ---
echo "-> Claude Code"
mkdir -p ~/.claude/hooks
ln -sf "$DOTFILES/claude/hooks/notify-waiting.sh" ~/.claude/hooks/notify-waiting.sh
ln -sf "$DOTFILES/claude/settings.json" ~/.claude/settings.json

# --- Dependencies ---
if command -v brew &>/dev/null; then
  if ! command -v terminal-notifier &>/dev/null; then
    echo "-> Installing terminal-notifier"
    brew install terminal-notifier
  fi
else
  echo "Warning: brew not found, skipping terminal-notifier install"
fi

echo "Done! Reload tmux with: tmux source ~/.config/tmux/tmux.conf"
