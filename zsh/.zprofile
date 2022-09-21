if command -v pdl &> /dev/null
then
  source $HOME/.pdl_zsh_auto_completion
  export GITHUB_ACCESS_TOKEN=$(pdl pat get)
fi

# Added by Toolbox App
export PATH="$PATH:/usr/local/bin"

# Homebrew
if [[ $(uname -p) == 'i386' ]]; then
  eval "$(/usr/local/Homebrew/bin/brew shellenv)"
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

