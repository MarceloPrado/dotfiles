#!/bin/bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "$0")" && pwd)"

echo "Installing dotfiles from $DOTFILES"

if ! command -v mise &>/dev/null; then
  if ! command -v curl &>/dev/null; then
    echo "Error: curl is required to install mise"
    exit 1
  fi

  echo "-> Installing mise"
  curl https://mise.run | sh
  echo "Installed mise. Open a new shell and rerun ./install.sh"
  exit 0
fi

echo "-> Installing repo tools with mise"
cd "$DOTFILES"
mise trust "$DOTFILES/mise.toml" >/dev/null
mise install

# --- Dependencies ---
if command -v brew &>/dev/null; then
  command -v stow &>/dev/null || brew install stow
  command -v terminal-notifier &>/dev/null || brew install terminal-notifier
  command -v tmux &>/dev/null || brew install tmux
  command -v fd &>/dev/null || brew install fd
  command -v fzf &>/dev/null || brew install fzf
  command -v rg &>/dev/null || brew install ripgrep
  if brew list neovim &>/dev/null; then
    brew upgrade neovim
  else
    brew install neovim
  fi
else
  echo "Warning: brew not found, skipping Homebrew-managed dependencies"
fi

if ! command -v stow &>/dev/null; then
  echo "Error: stow is required to install these dotfiles"
  exit 1
fi

# --- Stow packages ---
stow -t ~ nvim tmux zsh opencode ripgrep
stow -t ~ --no-folding --adopt claude

# --- Codex: tracked base config + gitignored generated config ---
echo "-> Codex config"
mise exec -- node "$DOTFILES/scripts/render-codex-config.js"
mkdir -p ~/.codex/hooks
rm -f ~/.codex/config.toml ~/.codex/hooks/notify-waiting.sh
stow -t ~ --no-folding codex

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
if [ ! -d ~/.config/tmux/plugins/tpm ]; then
  echo "-> Installing tmux plugin manager"
  mkdir -p ~/.config/tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
fi

if [ ! -d ~/.config/tmux/plugins/catppuccin/tmux ]; then
  echo "-> Installing catppuccin tmux theme"
  mkdir -p ~/.config/tmux/plugins/catppuccin
  git clone -b v2.1.3 https://github.com/catppuccin/tmux.git ~/.config/tmux/plugins/catppuccin/tmux
fi

echo "Done! Reload tmux with: tmux source ~/.config/tmux/tmux.conf"
