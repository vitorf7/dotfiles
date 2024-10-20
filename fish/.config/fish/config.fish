#
# ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██║██╔════╝██║  ██║
# █████╗  ██║███████╗███████║
# ██╔══╝  ██║╚════██║██╔══██║
# ██║     ██║███████║██║  ██║
# ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
# A smart and user-friendly command line
# https://fishshell.com/

# eval (/opt/homebrew/bin/brew shellenv)
/opt/homebrew/bin/brew shellenv | source
starship init fish | source # https://starship.rs/
zoxide init fish | source # 'ajeetdsouza/zoxide'
status --is-interactive; and rbenv init - fish | source


# set -U fish_greeting # disable fish greeting
set -U fish_key_bindings fish_vi_key_bindings

set -Ux BAT_THEME Catppuccin-mocha # 'sharkdp/bat' cat clone
set -Ux EDITOR nvim # 'neovim/neovim' text editor
set -Ux PAGER "~/.local/bin/nvimpager" # 'lucc/nvimpager'
set -Ux VISUAL nvim

# If you come from bash you might have to change your $PATH.
set -Ux HOMEBREW_PATH /opt/homebrew
set -l osProcessor (uname -p)
if test $osProcessor = i386
    set -Ux HOMEBREW_PATH /usr/local
end

set -Ux GOPATH $HOME/Code/go
set -Ux GOROOT $HOMEBREW_PATH/opt/go/libexec
set -Ux GOBIN $HOME/Code/go/bin
set -Ux GO111MODULE on
set -Ux XDG_CONFIG_HOME "$HOME/.config"
set -Ux STARSHIP_CONFIG "$HOME/.config/starship.toml"

source $XDG_CONFIG_HOME/fish/aliases.fish
# Private config (Env vars, aliases, etc)
source $XDG_CONFIG_HOME/fish/private_config.fish

if test $osProcessor = i386
    set -Ux GOROOT /usr/local/Cellar/go/1.19.1/libexec
end

set -Ux NODE_PATH $HOMEBREW_PATH/lib/node_modules

fish_add_path ~/.config/bin
fish_add_path /usr/local/opt/python/libexec/bin
fish_add_path $HOME/.local/share/bob/nvim-bin
fish_add_path "$GOPATH/bin"
fish_add_path "$GOROOT/bin"
fish_add_path "$HOME/.local/bin"
fish_add_path "$HOME/bin"
fish_add_path /usr/local/bin
fish_add_path /usr/local/sbin
fish_add_path "$HOMEBREW_PATH/opt"
fish_add_path "$HOME/.composer/vendor/bin"
fish_add_path "./vendor/bin"
fish_add_path "$HOMEBREW_PATH/opt/node@8/bin"
fish_add_path "$HOMEBREW_PATH/opt/coreutils/libexec/gnubin"
fish_add_path "$HOMEBREW_PATH/opt/findutils/libexec/gnubin"
fish_add_path "$HOMEBREW_PATH/opt/gnu-sed/libexec/gnubin"
fish_add_path "$HOME/tools/lua-language-server/bin/macOS"
fish_add_path "$HOMEBREW_PATH/opt/openjdk@11/bin"
fish_add_path "$HOMEBREW_PATH/opt/curl/bin"
fish_add_path "$HOME/.cargo/bin"
# ~/.tmux/plugins
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin
# ~/.config/tmux/plugins
fish_add_path $HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin

if test -d "$HOME/.local/share/nvim/mason/bin"
    fish_add_path "$HOME/.local/share/nvim/mason/bin"
end

alias pip pip3

set -Ux GPG_TTY (tty)

alias vim nvim

alias luamake $HOME/Code/lua-language-server/3rd/luamake/luamake

# The next line updates PATH for the Google Cloud SDK.
if test -f "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

set -gx NVM_DIR "$HOME/.nvm"
# bass source (brew --prefix nvm)/nvm.sh --no-use ';' nvm use iojs
# if test -s "$HOMEBREW_PATH/opt/nvm/nvm.sh"
#     bass source "$HOMEBREW_PATH/opt/nvm/nvm.sh"
# end
# set -gx NVM_DIR “$HOME/.nvm”
# # This loads nvm 
# [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; and . "/opt/homebrew/opt/nvm/nvm.sh"
# [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ]; and . "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" # This loads nvm bash_completion

set -Ux T_SESSION_NAME_INCLUDE_PARENT true

set -Ux DOCKER_HOST "unix://$HOME/.config/colima/default/docker.sock"

source /Users/vitorfaiante/.config/op/plugins.sh

# fish
fzf --fish | source

set -Ux FZF_DEFAULT_COMMAND "fd -H -E '.git'"

# set -Ux T_FZF_PROMPT "🔭 "
set -Ux T_FZF_PROMPT '  '

set -Ux fifc_editor nvim
