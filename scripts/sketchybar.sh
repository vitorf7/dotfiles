echo "Installing Dependencies"
# Packages
brew install lua
brew install switchaudio-osx
brew install nowplaying-cli
brew install media-control

brew tap FelixKratz/formulae
brew install sketchybar

# Fonts
brew install --cask sf-symbols
brew install --cask font-sf-mono
brew install --cask font-sf-pro

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# SbarLua — Homebrew readline is keg-only (not auto-linked). CPATH supplies
# the headers; LIBRARY_PATH supplies the lib to gcc at link time (propagates
# through nested make calls, unlike LDFLAGS which does not).
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && CPATH=/opt/homebrew/opt/readline/include LIBRARY_PATH=/opt/homebrew/opt/readline/lib make install && rm -rf /tmp/SbarLua/)
