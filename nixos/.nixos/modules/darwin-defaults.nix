{ ... }:
{
  flake.modules.darwin.defaults = { ... }: {
    system.defaults = {
      NSGlobalDomain = {
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 1;
        InitialKeyRepeat = 12;
        AppleInterfaceStyle = "Dark";
        "com.apple.swipescrolldirection" = false;
        AppleICUForce24HourTime = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        _HIHideMenuBar = true;
      };
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.15;
        show-recents = false;
        mru-spaces = false;
        show-process-indicators = true;
        mouse-over-hilite-stack = true;
        persistent-apps = [
          { app = "/System/Applications/Calendar.app"; }
          { app = "/Applications/Ghostty.app"; }
          { app = "/Applications/Ferdium.app"; }
          { app = "/Applications/Zen.app"; }
          { app = "/Applications/Postman.app"; }
          { spacer = { small = true; }; }
          { app = "/Applications/Arc.app"; }
          { app = "/Applications/kitty.app"; }
          { spacer = { small = true; }; }
          { app = "/Applications/Spotify.app"; }
          { app = "/System/Applications/System Settings.app"; }
        ];
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = false;
        FXPreferredViewStyle = "clmv";
        ShowPathbar = true;
        ShowStatusBar = true;
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

    system.activationScripts.extraActivation.text = ''
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
      defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
      defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40
      defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
      defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
      defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true
      defaults write com.apple.finder FXInfoPanesExpanded -dict \
        General -bool true OpenWith -bool true Privileges -bool true
      defaults write com.apple.dock expose-animation-duration -float 0.12
      mkdir -p "$HOME/Screenshots"
    '';
  };
}
