#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES"

# --- Stow packages ---
cd "$DOTFILES"
stow -t ~ nvim tmux zsh
stow -t ~ --no-folding claude codex

# --- tmux catppuccin theme ---
if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]; then
  echo "-> Installing catppuccin tmux theme"
  mkdir -p ~/.config/tmux/plugins/catppuccin
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
fi

# --- Dependencies ---
if command -v brew &>/dev/null; then
  command -v stow &>/dev/null || brew install stow
  command -v terminal-notifier &>/dev/null || brew install terminal-notifier
else
  echo "Warning: brew not found, skipping dependency install"
fi

echo "Done! Reload tmux with: tmux source ~/.config/tmux/tmux.conf"
