#export GITHUB_ACCESS_TOKEN=$(security find-generic-password -a "pdl" -s "paddle_github_access_token" -w)

# Added by Toolbox App
export PATH="$PATH:/usr/local/bin"

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
