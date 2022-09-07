source $HOME/.pdl_zsh_auto_completion
export GITHUB_ACCESS_TOKEN=$(pdl pat get)

# Added by Toolbox App
export PATH="$PATH:/usr/local/bin"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

