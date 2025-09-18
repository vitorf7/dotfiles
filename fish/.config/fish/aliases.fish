# Git
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"
alias gcm="git commit -m"
alias gcmps="gitCommitWithMessageAndPush"
alias gf="git fetch"
alias gpl="git pull"
alias gps="git push"
alias gst="git status"
alias gs="git switch"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gdf="git diff"
alias gch="git checkout"
alias gsw="git switch"
alias grs="git restore"
alias gbr="git branch"
alias gbrd="git branch -d"
alias gbra="git branch -a"
alias gw="git worktree"
alias gwr="git worktree remove"
alias gwl="git worktree list"
alias gwa="git worktree add"

function gwab -d "Create a new worktree with a branch (from another branch or remote branch if 2nd argument is provided)"
    set branchName $argv[1]

    # Check if originBranchName is provided as the second argument
    if count $argv > 1
        set originBranchName $argv[2]
    else
        set originBranchName $branchName
    end

    git worktree add -b $branchName $branchName $originBranchName
end

function gprune
    git fetch -p
    for branch in (git branch -vv | grep ': gone]' | awk '{print $1}')
        git branch -D $branch
    end
end

alias gsh="switch-to-head-branch"
function switch-to-head-branch -d "Find name of the origin/HEAD branch and switch to it"
    set gitOutput (git symbolic-ref refs/remotes/origin/HEAD)
    set branchName (string replace 'refs/remotes/origin/' '' $gitOutput)

    git switch $branchName
end

#PhpSpec
alias specr="phpspec run"
alias specrcat="phpspec run --format nyan.cat"
alias specrdino="phpspec run --format nyan.dino"
alias specrcrab="phpspec run --format nyan.crab"
alias specd="phpspec describe "

# Docker helpers
alias docker-stop-everything='docker stop $(docker ps -a -q)'
alias docker-killall='docker-stop-everything && docker rm $(docker ps -a -q)'
alias docker-prune='docker system prune -a --volumes -f'
alias docker-fresh='docker-stop-everything && docker-prune'

function docker-fatality
    echo '============      FINISH IT   ============'
    docker stop $(docker ps -a -q)
    docker rm $(docker ps -a -q)
    docker system prune -a --volumes -f
    echo '============      FATALITY    ============'
    echo '============ FLAWLESS VICTORY ============'
end

alias brew-up-to-date="brew update && brew upgrade"
alias brew-force-update-casks="brew update && brew upgrade --cask --greedy --force"
alias brew-upgrade-everything="brew update && brew upgrade && brew upgrade --cask --greedy --force"

# Exa alias for ls (https://github.com/ogham/exa)
alias lh="eza --icons -lha"
alias ls="eza --icons"

# Mac setup for pomo
alias work="timer 25m && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break 😊'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"

alias pairing-break="timer 5m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"

alias rest="timer 30m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work 😬'\
        -appIcon '~/Pictures/pumpkin.png'\
        -sound Crystal"

# cat
alias cat="bat"

# Ngrok
alias ngrok="ngrok --authtoken=$NGROK_AUTHTOKEN"

# GH GLI
# unset GITHUB_TOKEN from gh's process environment and run gh command.
# see https://stackoverflow.com/a/41749660 & https://github.com/cli/cli/issues/3799 for more.
alias gh="env -u GITHUB_TOKEN gh $1"

# Sesh (Tmux Session Manager)
alias t="sesh connect (sesh list -tz | fzf-tmux -p 55%,60% \
		--no-sort --border-label ' sesh ' --prompt '⚡  ' \
		--header '  ^a all ^t tmux ^x zoxide ^f find' \
		--bind 'tab:down,btab:up' \
		--bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list)' \
		--bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t)' \
		--bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z)' \
		--bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 3 -t d -E .Trash . $HOME $HOME/code/)' \
		--bind 'ctrl-d:execute(tmux kill-session -t {})+reload(sesh list)' \
)"

## Kill PID using fzf
alias killpid="kill -9 \$(lsof -i -n -P | fzf | awk '{print \$2}')"

## kubectl
alias kubectl="kubecolor"
alias k ="kubectl"

function close_neovim_in_tmux
    # Get a list of all tmux sessions
    set sessions (tmux list-sessions -F "#{session_name}" 2>/dev/null)
    
    if test -z "$sessions"
        echo "No tmux sessions found"
        return
    end

    set found_nvim false

    # Loop through each session
    for session in $sessions
        # Get all windows in the session
        set windows (tmux list-windows -t $session -F "#{window_index}" 2>/dev/null)

        # Loop through each window
        for window in $windows
            # Get all panes in the window
            set panes (tmux list-panes -t $session:$window -F "#{pane_id}" 2>/dev/null)

            for pane in $panes
                # Check the command running in the pane (including full command line)
                set cmd (tmux display-message -p -t $pane "#{pane_current_command}" 2>/dev/null)
                set full_cmd (tmux display-message -p -t $pane "#{pane_current_path} #{pane_current_command}" 2>/dev/null)

                # Check for nvim, vim, or any variation
                if string match -q "*nvim*" "$cmd" "$full_cmd"
                    set found_nvim true
                    echo "Found Neovim in $session:$window:$pane (command: $cmd)"

                    # Try multiple approaches to quit Neovim
                    # First, try gentle quit
                    tmux send-keys -t $pane 'Escape' ':qa!' 'Enter'
                    sleep 0.5

                    # Check if still running
                    set new_cmd (tmux display-message -p -t $pane "#{pane_current_command}" 2>/dev/null)
                    if string match -q "*nvim*" "$new_cmd"
                        echo "Gentle quit failed, trying force quit for $pane"
                        # Try Ctrl+C followed by quit
                        tmux send-keys -t $pane 'C-c'
                        sleep 0.2
                        tmux send-keys -t $pane 'Escape' ':qa!' 'Enter'
                        sleep 0.5

                        # Final check and nuclear option
                        set final_cmd (tmux display-message -p -t $pane "#{pane_current_command}" 2>/dev/null)
                        if string match -q "*nvim*" "$final_cmd"
                            echo "Force quitting process in $pane"
                            tmux send-keys -t $pane 'C-z'  # Suspend
                            sleep 0.2
                            tmux send-keys -t $pane 'kill %1' 'Enter'  # Kill suspended job
                        end
                    else
                        echo "Successfully closed Neovim in $pane"
                    end
                end
            end
        end
    end

    if not $found_nvim
        echo "No Neovim instances found in tmux sessions"
    else
        echo "Waiting for processes to fully terminate..."
        sleep 1
        echo "Done processing Neovim instances"
    end
end

function kill_all_neovim
    echo "Looking for all Neovim processes..."
    
    # Find all nvim processes
    set nvim_pids (pgrep -f "nvim" 2>/dev/null)
    
    if test -z "$nvim_pids"
        echo "No Neovim processes found"
        return
    end
    
    echo "Found Neovim processes: $nvim_pids"
    
    # First try graceful termination
    for pid in $nvim_pids
        echo "Sending TERM signal to PID $pid"
        kill -TERM $pid 2>/dev/null
    end
    
    sleep 2
    
    # Check what's still running and force kill if necessary
    set remaining_pids (pgrep -f "nvim" 2>/dev/null)
    if test -n "$remaining_pids"
        echo "Force killing remaining processes: $remaining_pids"
        for pid in $remaining_pids
            kill -KILL $pid 2>/dev/null
        end
    end
    
    echo "All Neovim processes terminated"
end
