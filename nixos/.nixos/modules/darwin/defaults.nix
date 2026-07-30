{ ... }:

{
  system.defaults = {
    NSGlobalDomain = {
      # Disable press-and-hold accent popup so key-repeat works in Neovim.
      ApplePressAndHoldEnabled = false;
      # Fast key repeat (scripts/macos.sh: KeyRepeat=1 InitialKeyRepeat=12).
      KeyRepeat = 1;
      InitialKeyRepeat = 12;
      # Dark mode system-wide.
      AppleInterfaceStyle = "Dark";
      # Disable "natural" (reversed) scroll direction.
      "com.apple.swipescrolldirection" = false;
      # 24-hour clock.
      AppleICUForce24HourTime = true;
      # Disable auto-correct annoyances.
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      # Always hide the native menu bar — Sketchybar replaces it.
      _HIHideMenuBar = true;
    };
    dock = {
      autohide = true;
      autohide-delay = 0.0;
      autohide-time-modifier = 0.15;
      show-recents = false;
      # Don't rearrange spaces based on most recent use (Aerospace-friendly).
      mru-spaces = false;
      show-process-indicators = true;
      mouse-over-hilite-stack = true;

      # Order in the list = left-to-right order in the Dock.
      # nrs replaces this list on every activation — items dragged in manually
      # will be removed on the next rebuild.
      persistent-apps = [
        # Finder is always pinned automatically by macOS — omit it here to avoid
        # a duplicate entry with a ? placeholder.
        {app = "/System/Applications/Calendar.app";}
        {app = "/Applications/Ghostty.app";}
        {app = "/Applications/Rambox.app";}
        {app = "/Applications/Zen.app";}
        {app = "/Applications/Postman.app";}
        {
          spacer = {
            small = true;
          };
        }
        {app = "/Applications/Arc.app";}
        {app = "/Applications/kitty.app";}
        {
          spacer = {
            small = true;
          };
        }
        {app = "/Applications/Spotify.app";}
        {app = "/System/Applications/System Settings.app";}
      ];
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = false;
      FXPreferredViewStyle = "clmv"; # column view
      ShowPathbar = true;
      ShowStatusBar = true;
      # Don't warn when changing file extensions.
      FXEnableExtensionChangeWarning = false;
    };

    screencapture = {
      location = "~/Screenshots";
      type = "png";
    };

    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };

    loginwindow.GuestEnabled = false;
  };

  # Defaults with no dedicated nix-darwin option — applied via activation script.
  system.activationScripts.extraActivation.text = ''
    # Avoid .DS_Store pollution on network/USB volumes (scripts/macos.sh)
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Bluetooth audio quality (scripts/macos.sh)
    defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

    # Finder: open new window when volume mounts
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

    # Finder: expand General/OpenWith/Privileges panes in File Info
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
      General -bool true OpenWith -bool true Privileges -bool true

    # Dock: speed up Mission Control animations
    defaults write com.apple.dock expose-animation-duration -float 0.12

    # Make ~/Screenshots if absent (screencapture.location refers to it)
    mkdir -p "$HOME/Screenshots"
  '';
}
