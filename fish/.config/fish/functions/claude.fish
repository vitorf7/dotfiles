# function claude --description 'claude-code with an isolated HOME to skip the sandbox deny-glob walk over /nix/store'
#     set -l real $HOME
#     if not string match -q -- '*/.claude-home' $real; and test -d $real/.claude-home
#         begin
#             set -lx HOME $real/.claude-home
#             set -lx CLAUDE_CONFIG_DIR $real/.claude
#             set -lx XDG_CONFIG_HOME $real/.config
#             set -lx XDG_CACHE_HOME $real/.cache
#             set -lx XDG_DATA_HOME $real/.local/share
#             set -lx CARGO_HOME $real/.cargo
#             set -lx GOPATH $real/go
#             set -lx GOCACHE $real/.cache/go-build
#             set -lx npm_config_cache $real/.npm
#             if test -r $real/.kube/config
#                 set -lx KUBECONFIG $real/.kube/config
#             end
#             command claude $argv
#         end
#     else
#         command claude $argv
#     end
# end

function claude --description 'claude-code with an isolated HOME to skip the sandbox deny-glob walk over /nix/store'
    command  bwrap --bind / / --dev /dev --proc /proc \
            --tmpfs "$HOME/.nix-defexpr" \
            --tmpfs "$HOME/.local/state/nix" \
            --tmpfs "$HOME/.local/state/home-manager" \
            --tmpfs "$HOME/.mytest" \
            claude $argv
end
