#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES"

# --- Stow packages ---
cd "$DOTFILES"
stow -t ~ nvim tmux zsh opencode ripgrep
stow -t ~ --no-folding --adopt claude codex

# --- Claude Code: machine-specific settings ---
HOSTNAME=$(hostname)
if [[ "$HOSTNAME" == "Marcelos-Mac-Studio.local" || "$HOSTNAME" == "Marcelos-MacBook-Air.local" ]]; then
  PROFILE="personal"
else
  PROFILE="work"
fi
echo "-> Claude Code settings ($PROFILE)"
ln -sf "$DOTFILES/claude/.claude/settings.$PROFILE.json" ~/.claude/settings.json

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
  command -v tmux &>/dev/null || brew install tmux
  if brew list neovim &>/dev/null; then
    brew upgrade neovim
  else
    brew install neovim
  fi
  command -v fzf &>/dev/null || brew install fzf
  command -v rg &>/dev/null || brew install ripgrep
else
  echo "Warning: brew not found, skipping dependency install"
fi

echo "Done! Reload tmux with: tmux source ~/.config/tmux/tmux.conf"
