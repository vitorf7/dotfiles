if [ "$TMUX" = "" ]; then tmux; fi
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export XDG_CONFIG_HOME="$HOME/.config"

# Private config (Env vars, aliases, etc)
source $HOME/.private_config

# If you come from bash you might have to change your $PATH.
export HOMEBREW_PATH=/opt/homebrew
if [[ $(uname -p) == 'i386' ]]; then
  export HOMEBREW_PATH=/usr/local
fi

export GOPATH=$HOME/Code/go
export GOROOT=$HOMEBREW_PATH/opt/go/libexec
export GOBIN=$HOME/Code/go/bin
if [[ $(uname -p) == 'i386' ]]; then
  export GOROOT=/usr/local/Cellar/go/1.19.1/libexec
fi

export NODE_PATH=$HOMEBREW_PATH/lib/node_modules

export PATH="$HOME/bin:/usr/local/bin:$HOMEBREW_PATH/opt:/usr/local/sbin:$HOME/.composer/vendor/bin:./vendor/bin:$HOMEBREW_PATH/opt/node@8/bin:$PATH"
export PATH="$HOMEBREW_PATH/opt/coreutils/libexec/gnubin:$PATH"
export PATH="$PATH:$GOPATH/bin"
export PATH="$PATH:$GOROOT/bin"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$HOMEBREW_PATH/opt/findutils/libexec/gnubin:$PATH"
export PATH="$HOMEBREW_PATH/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/tools/lua-language-server/bin/macOS:$PATH"
export PATH="$HOMEBREW_PATH/opt/openjdk@11/bin:$PATH"

if [ -d "$HOME/.local/share/nvim/mason/bin" ] || [ -L "$HOME/.local/share/nvim/mason/bin" ]; then
  export PATH="$HOME/.local/share/nvim/mason/bin/:$PATH"
fi

export GO111MODULE=on

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"


source ~/.aliases

if [[ $(uname -p) == 'i386' ]]; then
  . $HOMEBREW_PREFIX/etc/profile.d/z.sh
else
  . $HOMEBREW_PATH/etc/profile.d/z.sh
fi

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export FZF_DEFAULT_OPTS="--cycle --multi --reverse --inline-info --preview 'file --mime-type {} | sift -q text/plain && cat {} || echo blob' --preview-window righ    t:60%:hidden --bind \?:toggle-preview --bind pgup:preview-page-up --bind pgdn:preview-page-down"

alias pip=pip3

export GPG_TTY=$(tty)

alias vim='nvim'
export EDITOR='nvim'

# Run neofetch when the terminal starts
neofetch

alias luamake=$HOME/Code/lua-language-server/3rd/luamake/luamake

# To customize prompt, run `p10k configure` or edit ~/configfiles/zsh/.p10k.zsh.
[[ ! -f ~/configfiles/zsh/.p10k.zsh ]] || source ~/configfiles/zsh/.p10k.zsh


# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/google-cloud-sdk/completion.zsh.inc"; fi

export NVM_DIR="$HOME/.nvm"
  [ -s "$HOMEBREW_PATH/opt/nvm/nvm.sh" ] && \. "$HOMEBREW_PATH/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "$HOMEBREW_PATH/opt/nvm/etc/bash_completion.d/nvm" ] && \. "$HOMEBREW_PATH/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

eval "$(rbenv init - zsh)"
