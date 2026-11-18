# dotfiles

macOS terminal setup: iTerm2 + tmux + Neovim, with Caps Lock as the tmux prefix.

- `nvim/`: Neovim config, symlink to `~/.config/nvim`
- `tmux/.tmux.conf`: symlink to `~/.tmux.conf`
- `karabiner/`: Karabiner-Elements config, symlink to `~/.config/karabiner`
- `macos/defaults.sh`: macOS settings, run once

## Setup

Run from the repo root.

```sh
brew install neovim tree-sitter-cli ripgrep tmux
brew install --cask iterm2 karabiner-elements rectangle
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

mkdir -p ~/.config
ln -s "$PWD/nvim" ~/.config/nvim
ln -s "$PWD/tmux/.tmux.conf" ~/.tmux.conf
ln -s "$PWD/karabiner" ~/.config/karabiner
```

## Neovim

Requires Neovim 0.12+.

`tree-sitter-cli` builds treesitter parsers; `ripgrep` backs Telescope.
Then run `:Lazy sync` in nvim.

## tmux

Prefix is `C-a`. Press `prefix + I` once to install the plugins.

## Caps Lock as tmux prefix

tmux cannot see Caps Lock, so Karabiner-Elements sends `C-a` for it while iTerm2 is in front.
Other apps keep the normal Caps Lock.

Link the whole `karabiner/` folder, not the json file, or Karabiner stops seeing changes.
Open Karabiner-Elements once and allow what it asks for in System Settings.

## macOS

```sh
./macos/defaults.sh
```

Sets Dock auto-hide and speed, scroll direction, dark mode, Simplified Chinese as the language, a black desktop, and turns off built-in window tiling.
Log out and back in after. Changes made later in System Settings are not saved here; add them to the script by hand.

## Rectangle

Window snapping with keyboard shortcuts. Open it once and allow Accessibility when it asks.

## iTerm2

Stock settings, except:

- Font: Monaco 14 (Settings → Profiles → Text)
- Clipboard access for terminal apps: `defaults write com.googlecode.iterm2 AllowClipboardAccess -bool true`
