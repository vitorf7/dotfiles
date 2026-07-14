#
# ███████╗██╗███████╗██╗  ██╗
# ██╔════╝██║██╔════╝██║  ██║
# █████╗  ██║███████╗███████║
# ██╔══╝  ██║╚════██║██╔══██║
# ██║     ██║███████║██║  ██║
# ╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝
# A smart and user-friendly command line
# https://fishshell.com/

if test -z "$IN_NIX_SHELL"
    if command -s /opt/homebrew/bin/brew > /dev/null
        eval (/opt/homebrew/bin/brew shellenv)
    end
end

set starshipCLI (which starship)
set zoxideCLI (which zoxide)
set direnvCLI (which direnv)
set fxCLI (which fx)
set fastfetchCLI (which fastfetch)
set deltaCLI (which delta)
set miseCLI (which mise)

$starshipCLI init fish | source # https://starship.rs/
$zoxideCLI init fish | source # 'ajeetdsouza/zoxide'
$direnvCLI hook fish | source # https://direnv.net/
$fxCLI --comp fish | source # https://fx.wtf/
set -g direnv_fish_mode eval_on_arrow # trigger direnv at prompt, and on every arrow-based directory change (default)
eval "$($miseCLI activate fish)"   # or bash/fish

# override the default greeting
function fish_greeting
    # Select the image directory, preferring Wallpapers, then backgrounds
    set image_dir ""
    if test -d $HOME/Pictures/Wallpapers
        set image_dir $HOME/Pictures/Wallpapers
    else if test -d $HOME/Pictures/backgrounds
        set image_dir $HOME/Pictures/backgrounds
    end

    if test -n "$image_dir"
        # Get a random image file from the selected directory
        set random_image (find $image_dir -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif' \) | shuf -n 1)

        if test -n "$random_image"
            $fastfetchCLI --kitty-icat (echo $random_image) --logo-height 50 --logo-width 50
        else
            $fastfetchCLI
        end
    else
        $fastfetchCLI
    end
end

set -U fish_key_bindings fish_vi_key_bindings
#
#set -Ux BAT_THEME Catppuccin-mocha # 'sharkdp/bat' cat clone
set -Ux EDITOR nvim # 'neovim/neovim' text editor
set -Ux PAGER $deltaCLI
set -Ux VISUAL nvim
set -Ux SUDO_EDITOR $HOME/.local/share/bob/nvim-bin/nvim
set -Ux JAVA_HOME /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

if  test -n $HOMEBREW_PATH
    set -Ux NODE_PATH $HOMEBREW_PREFIX/lib/node_modules
end

set -Ux XDG_CONFIG_HOME "$HOME/.config"
set -Ux STARSHIP_CONFIG "$HOME/.config/starship.toml"

source $XDG_CONFIG_HOME/fish/aliases.fish
# Private config (Env vars, aliases, etc)
if test -e $XDG_CONFIG_HOME/fish/private_config.fish
    source $XDG_CONFIG_HOME/fish/private_config.fish
end

alias pip pip3

set -Ux GPG_TTY (tty)

alias vim nvim

alias luamake $HOME/Code/lua-language-server/3rd/luamake/luamake

set -gx NVM_DIR "$HOME/.nvm"
set --universal nvm_default_version latest
set --global nvm_data $HOME/.nvm
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

if test -f $HOME/.config/op/plugins.sh
  source $HOME/.config/op/plugins.sh
end

# fish
fzf --fish | source

set -Ux FZF_DEFAULT_COMMAND "fd -H -E '.git'"
set -Ux FZF_DEFAULT_OPTS "--layout=reverse --info=inline --margin=8,15 --border"

set -Ux T_FZF_PROMPT "🔭 "
# set -Ux T_FZF_PROMPT '  '

set -Ux fifc_editor nvim

## The next line updates PATH for the Google Cloud SDK.
if test -f "$HOME/google-cloud-sdk/path.zsh.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

# npm - redirect global installs away from the read-only Nix store
set -Ux NPM_CONFIG_PREFIX "$HOME/.npm-global"
fish_add_path $HOME/.npm-global/bin

# Go SDK managed by go-update (always latest from go.dev)
if test -L "$HOME/.local/share/go-sdk/current"
    set -gx GOROOT "$HOME/.local/share/go-sdk/current/share/go"
    fish_add_path "$HOME/.local/share/go-sdk/current/bin"
end

# golang - https://golang.google.cn/
set -Ux GOPATH $HOME/go
set -Ux GO111MODULE on

fish_add_path $GOPATH/bin
fish_add_path $HOME/.local/share/bob/nvim-bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.config/bin # my custom scripts
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/Library/Python/3.9/bin
# ~/.tmux/plugins
fish_add_path $HOME/.tmux/plugins/t-smart-tmux-session-manager/bin
# ~/.config/tmux/plugins
fish_add_path $HOME/.config/tmux/plugins/t-smart-tmux-session-manager/bin
fish_add_path $HOME/.krew/bin
fish_add_path $HOME/.rbenv/bin

if test -d "$HOME/.local/share/nvim/mason/bin"
    fish_add_path "$HOME/.local/share/nvim/mason/bin"
end

# if fzf-git.fish file exists then source it
if test -e "$HOME/.config/fzf-git/fzf-git.fish"
    source "$HOME/.config/fzf-git/fzf-git.fish"
end

# set -e SSH_AUTH_SOCK
# set -Ux SSH_AUTH_SOCK $HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock

# set rbenvCLI (which rbenv)
# eval ($rbenvCLI init -)

##fish_add_path ~/.config/bin
##fish_add_path /usr/local/opt/python/libexec/bin
##fish_add_path "$GOPATH/bin"
##fish_add_path "$GOROOT/bin"
##fish_add_path "$HOME/.local/bin"
##fish_add_path "$HOME/bin"
##fish_add_path /usr/local/bin
##fish_add_path /usr/local/sbin
##fish_add_path "$HOMEBREW_PATH/opt"
##fish_add_path "$HOME/.composer/vendor/bin"
##fish_add_path "./vendor/bin"
##fish_add_path "$HOMEBREW_PATH/opt/node@8/bin"
##fish_add_path "$HOMEBREW_PATH/opt/coreutils/libexec/gnubin"
##fish_add_path "$HOMEBREW_PATH/opt/findutils/libexec/gnubin"
##fish_add_path "$HOMEBREW_PATH/opt/gnu-sed/libexec/gnubin"
##fish_add_path "$HOME/tools/lua-language-server/bin/macOS"
##fish_add_path "$HOMEBREW_PATH/opt/openjdk@11/bin"
##fish_add_path "$HOMEBREW_PATH/opt/curl/bin"
##fish_add_path "$HOME/.cargo/bin"
##

# Added by `rbenv init` on Wed 13 Aug 2025 13:11:31 BST
status --is-interactive; and rbenv init - --no-rehash fish | source

if set -q IN_NIX_SHELL
    set -l nix_paths
    set -l other_paths
    set -l nix_prefixes /nix/store /nix/var/nix $HOME/.nix-profile

    for dir in $PATH
        set -l is_nix 0

        for prefix in $nix_prefixes
            if string match -q "$prefix*" -- $dir
                set is_nix 1
                break
            end
        end

        if test $is_nix -eq 1
            contains -- $dir $nix_paths
            or set -a nix_paths $dir
        else
            contains -- $dir $other_paths
            or set -a other_paths $dir
        end
    end

    set -gx PATH $nix_paths $other_paths
end
