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
- installs or upgrades `neovim`
- installs `fzf`, `ripgrep`, `tmux`, and other small dependencies

The Neovim config is intentionally minimal:

- Treesitter syntax highlighting
- `fzf-lua` for file search and grep
- native LSP with `gd`, `gr` (references picker), and `gh`
- Mason-managed TypeScript/JavaScript language server
