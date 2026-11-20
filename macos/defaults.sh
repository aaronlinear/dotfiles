#!/bin/sh
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.15
defaults write com.apple.dock showAppExposeGestureEnabled -bool true

defaults write com.apple.dock persistent-apps -array
for app in \
  "/Applications/Google Chrome.app" \
  /Applications/LarkSuite.app \
  /Applications/Slack.app \
  /Applications/iTerm.app \
  /Applications/Spotify.app \
  /Applications/Tailscale.app \
  "/System/Applications/System Settings.app"
do
  defaults write com.apple.dock persistent-apps -array-add \
    "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
done
defaults write com.apple.dock persistent-others -array \
  "<dict><key>tile-type</key><string>directory-tile</string><key>tile-data</key><dict><key>file-type</key><integer>2</integer><key>arrangement</key><integer>2</integer><key>displayas</key><integer>0</integer><key>showas</key><integer>1</integer><key>file-data</key><dict><key>_CFURLString</key><string>$HOME/Downloads/</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"

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
