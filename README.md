# dotfiles

- `nvim/`: Neovim config, symlinked to `~/.config/nvim`
- `tmux/.tmux.conf`: symlinked to `~/.tmux.conf`

## Neovim version

**This config targets Neovim 0.12+** (tested on 0.12.6). It is no longer
compatible with 0.10.

We briefly pinned everything to 0.10 (commit `6a5cb13`) and have now moved back
to current releases:

- nvim-treesitter and nvim-treesitter-textobjects use the `main` branch. The
  old `master` branch is frozen and crashes on 0.11+ with
  `tsrange.lua:27: attempt to call method 'start' (a nil value)`.
- LSP uses the native `vim.lsp.config` / `vim.lsp.enable` API through
  mason-lspconfig 2.x, instead of the old `require("lspconfig").X.setup()`.
- mason, mason-lspconfig, nvim-lspconfig and telescope are no longer pinned to
  their 0.10-compatible versions.

### Setup

```sh
brew install neovim tree-sitter-cli ripgrep
```

The tree-sitter CLI is required: nvim-treesitter `main` builds parsers with it.
Then open nvim and run `:Lazy sync` to update plugins and `lazy-lock.json`.
