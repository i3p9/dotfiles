#!/usr/bin/env bash
# macOS preferences — run on a fresh machine to restore tuned settings.
# Idempotent: re-running won't break anything.
# Usage: ~/dotfiles/scripts/macos-defaults.sh
#
# Captured from this machine on 2026-04-28. Re-probe and update as you tune.

set -u

echo "→ Closing System Settings to avoid overwriting changes mid-flight…"
osascript -e 'tell application "System Settings" to quit' 2>/dev/null || true

# ─────────────────────── UI / appearance ───────────────────────
defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# ─────────────────────── Text input ───────────────────────
# Autocorrect off; other substitutions left at OS default (on).
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool true
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool true
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool true

# ─────────────────────── Finder ───────────────────────
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"   # List view
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"   # Search current folder
defaults write com.apple.finder NewWindowTarget -string "PfHm"        # New windows open ~

# ─────────────────────── Dock ───────────────────────
defaults write com.apple.dock tilesize -int 38
defaults write com.apple.dock largesize -int 36
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock mineffect -string "genie"
defaults write com.apple.dock orientation -string "bottom"
defaults write com.apple.dock show-recents -bool false

# ─────────────────────── Screenshots ───────────────────────
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# ─────────────────────── Trackpad ───────────────────────
# Tap-to-click on (both built-in and Bluetooth trackpads)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool false

# ─────────────────────── Optional extras (uncomment to enable) ───────────────────────
# Common tweaks you don't currently have set — review and uncomment what you want.

# # Faster key repeat (lower = faster). System Settings minimum is 2.
# defaults write NSGlobalDomain KeyRepeat -int 2
# defaults write NSGlobalDomain InitialKeyRepeat -int 15

# # Disable press-and-hold accent picker, enable normal key repeat for Vim/etc.
# defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# # Full keyboard access — Tab through every UI control, not just text fields.
# defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# # Save/Print panels expanded by default.
# defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
# defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true

# # Show hidden files in Finder (cmd-shift-. toggles too).
# defaults write com.apple.finder AppleShowAllFiles -bool true

# # Show full POSIX path in Finder window title.
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# # Don't warn when changing a file extension.
# defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# # Avoid creating .DS_Store files on network and USB volumes.
# defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# # Disable the "Are you sure you want to open this app from the internet?" prompt.
# defaults write com.apple.LaunchServices LSQuarantine -bool false

# # Default TextEdit to plain-text mode.
# defaults write com.apple.TextEdit RichText -int 0

# # Screenshots as PNG (default), no drop shadow on window screenshots.
# defaults write com.apple.screencapture type -string "png"
# defaults write com.apple.screencapture disable-shadow -bool true

# ─────────────────────── Apply ───────────────────────
echo "→ Restarting Finder, Dock, SystemUIServer to apply…"
for app in Finder Dock SystemUIServer cfprefsd; do
  killall "$app" 2>/dev/null || true
done

echo "✓ Done. A logout/login may be needed for a few settings to fully apply."
