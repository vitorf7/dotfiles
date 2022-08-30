echo "Installing homebrew ..."

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo "Copying Brewfile"

cp ../homebrew/Brewfile $HOME/.Brewfile

echo "Install All homebrew dependencies using brew bundle"

brew bundle --global --verbose --force
