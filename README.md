# dotfiles

Personal config for Neovim, tmux, zsh, Claude Code, and a few CLI tools.

## Install

```bash
git clone https://github.com/marceloprado/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script:

- bootstraps `mise` with `curl https://mise.run | sh` when needed
- installs the repo's local `node` version from `mise.toml`
- stows the repo packages into `~`
- renders the gitignored `codex/.codex/config.toml` from the tracked Codex base config before stowing Codex into `~`
- installs `stow`, `neovim`, `fzf`, `ripgrep`, `tmux`, and `terminal-notifier` with Homebrew when available

## Mise tools

`mise.toml` is only for the repo-local Node.js version.

If you want tools to be global with mise, they need to live in your user config (`~/.config/mise/config.toml`) or be installed with `mise use -g ...`; a repo `mise.toml` is local to that repo.

In this repo, the other shared CLI tools stay global through Homebrew instead.

After pulling Node version changes on another machine, rerun `./install.sh` or `mise install` from the repo root.

## Codex config

Tracked shared Codex defaults live in `codex/.codex/config.base.toml`.

`./install.sh` runs `node scripts/render-codex-config.js`, which copies the base config into the gitignored `codex/.codex/config.toml` file and preserves everything after the `# -- END BASE CONFIG --` marker.

Put machine-specific Codex overrides and trusted project entries after that marker in `codex/.codex/config.toml`. The script keeps that local section in place on future installs while refreshing the base section from `config.base.toml`.

After pulling Codex base-config changes on another machine, rerun `./install.sh` once to refresh the generated Codex config and restow it.

The Neovim config is intentionally minimal:

- Treesitter syntax highlighting
- `fzf-lua` for file search and grep
- native LSP with `gd`, `gr` (references picker), and `gh`
- Catppuccin that follows macOS light/dark mode (`Latte`/`Mocha`)
- Mason-managed TypeScript/JavaScript language server
