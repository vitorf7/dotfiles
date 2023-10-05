# Added by Toolbox App
export PATH="$PATH:/usr/local/bin"

# Homebrew
if [[ $(uname -p) == 'i386' ]]; then
  eval "$(/usr/local/Homebrew/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

# ~/.tmux/plugins
export PATH=$HOME/.tmux/plugins/t-smart-tmux-session-manager/bin:$PATH
# ~/.config/tmux/plugins
export PATH=$HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin:$PATH
