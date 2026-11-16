# dotfiles

- `nvim/`: Neovim config, symlink to `~/.config/nvim`
- `tmux/.tmux.conf`: symlink to `~/.tmux.conf`

## Neovim

Requires Neovim 0.12+.

```sh
brew install neovim tree-sitter-cli ripgrep
```

`tree-sitter-cli` builds treesitter parsers; `ripgrep` backs Telescope.
Then run `:Lazy sync` in nvim.
