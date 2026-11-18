#!/bin/sh
# macOS settings. Run once on a new Mac, then log out and back in.

# Dock: auto-hide, no wait before it shows, fast slide
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15

# App Exposé trackpad gesture on
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

# Natural scrolling off
defaults write -g com.apple.swipescrolldirection -bool false

# Dark mode
defaults write -g AppleInterfaceStyle -string Dark

# Language: Simplified Chinese first, then English
defaults write -g AppleLanguages -array zh-Hans-US en-US
defaults write -g AppleLocale -string zh-Hans_US

# Black desktop background (asks once to let the terminal control System Events)
osascript -e 'tell application "System Events" to tell every desktop to set picture to "/System/Library/Desktop Pictures/Solid Colors/Black.png"'

# Built-in window tiling off (Rectangle does this instead)
defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

killall Dock
