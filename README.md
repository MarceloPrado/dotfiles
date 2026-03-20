# dotfiles

Personal config for Neovim, tmux, zsh, Claude Code, and a few CLI tools.

## Install

```bash
git clone https://github.com/marceloprado/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

The install script:

- stows the repo packages into `~`
- renders the gitignored `codex/.codex/config.toml` from the tracked Codex base config before stowing Codex into `~`
- installs or upgrades `neovim`
- installs `fzf`, `ripgrep`, `tmux`, and other small dependencies

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
