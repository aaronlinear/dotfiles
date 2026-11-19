#!/bin/sh
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

defaults write -g com.apple.swipescrolldirection -bool false
defaults write -g AppleInterfaceStyle -string Dark
defaults write -g AppleLanguages -array zh-Hans-US en-US
defaults write -g AppleLocale -string zh-Hans_US

osascript -e 'tell application "System Events" to tell every desktop to set picture to "/System/Library/Desktop Pictures/Solid Colors/Black.png"'

defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
defaults write com.apple.WindowManager EnableTilingOptionAccelerator -bool false
defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false

killall Dock
