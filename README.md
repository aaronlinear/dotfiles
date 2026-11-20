# dotfiles

macOS setup: apps and Dock layout, plus iTerm2, tmux and Neovim 0.12+ with Caps Lock as the tmux prefix.

Run from the repo root:

```sh
brew bundle
curl -fsSL https://claude.ai/install.sh | bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

mkdir -p ~/.config
ln -s "$PWD/nvim" ~/.config/nvim
ln -s "$PWD/tmux/.tmux.conf" ~/.tmux.conf
ln -s "$PWD/karabiner" ~/.config/karabiner

./macos/defaults.sh
defaults write com.googlecode.iterm2 AllowClipboardAccess -bool true
```

Then:

- Log out and back in.
- Open Karabiner-Elements, Rectangle and Tailscale once and allow what they ask for.
- nvim: run `:Lazy sync`.
- tmux: press `C-a I` to install the plugins.
- iTerm2: set the font to Monaco 14.

Karabiner sends `C-a` for Caps Lock only while iTerm2 is in front.
Link the whole `karabiner/` folder, not the json file, or Karabiner stops seeing changes.
