function claude --description 'claude-code with an isolated HOME to skip the sandbox deny-glob walk over /nix/store'
    set -l real $HOME
    if not string match -q -- '*/.claude-home' $real; and test -d $real/.claude-home
        begin
            set -lx HOME $real/.claude-home
            command claude $argv
        end
    else
        command claude $argv
    end
end
