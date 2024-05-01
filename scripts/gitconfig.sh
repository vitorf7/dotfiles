// gpg --list-secret-keys --keyid-format=long

read -p "Please enter the git name to be used: " gitName
read -p "Please enter the git email to be used: " gitEmail
read -p "Which signing key do you want to use: " signingKey
read -p "Do you want to be able to download private modules (Y/N): " usePrivateModules
if [[ $usePrivateModules == "Y" ]]; then
	read -p "Please enter a GitHub access token to be used: " ghToken
	read -p "What is the github organisation root name: " ghOrg
fi
read -p "Do you want to add a personal git configuration (Y/N): " addPersonalConfig
if [[ $addPersonalConfig == "Y" ]]; then
	read -p "Please enter the personal git name to be used: " personalGitName
	read -p "Please enter the personal git email to be used: " personalGitEmail
	read -p "Which personal signing key do you want to use: " personalSigningKey
	read -p "What is the personal work root code location: " personalCodeLocation
fi

echo "The GitHub access token you enter was $ghToken"

cat <<EOF >$HOME/.gitconfig
[user]
  email = $gitEmail
  name = $gitName
  signingKey = $signingKey
[core]
  editor = nvim
  excludesFile = ~/.gitignore_global
  pager = delta
[interactive]
  diffFilter = delta --color-only
[delta]
  navigate = true    # use n and N to move between diff sections
  side-by-side = true
  # delta detects terminal colors automatically; set one of these to disable auto-detection
  # dark = true
  # light = true
[merge]
  conflictstyle = diff3
[diff]
  colorMoved = default
[init]
  defaultBranch = master
[status]
  short = true
[gpg]
  format = ssh
[gpg "ssh"]
  program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign
[commit]
  gpgsign = true
[alias]
  leaderboard = shortlog --summary --numbered --all --no-merges
  sbr = "!rm ${GIT_PREFIX}$1 && git checkout -- ${GIT_PREFIX}$1 #"
[filter "strongbox"]
	clean = strongbox -clean %f
	smudge = strongbox -smudge %f
	required = true
[diff "strongbox"]
	textconv = strongbox -diff
[credential "https://github.com"]
	helper = 
	helper = !/opt/homebrew/bin/gh auth git-credential
[credential "https://gist.github.com"]
	helper = 
	helper = !/opt/homebrew/bin/gh auth git-credential
EOF

if [[ $usePrivateModules == "Y" ]]; then
	cat <<EOF >>$HOME/.gitconfig
[url "https://$ghToken:@github.com/$ghOrg"]
  insteadOf = https://github.com/$ghOrg
EOF
fi

if [[ $addPersonalConfig == "Y" ]]; then
	cat <<EOF >>$HOME/.gitconfig
[includeIf "gitdir:$personalCodeLocation"]
  path = ~/.gitconfig.personal
[includeIf "gitdir:~/configfiles/"]
  path = ~/.gitconfig.personal
EOF

	mkdir -p $personalCodeLocation

	cat <<EOF >>$HOME/.gitconfig.personal
[user]
  email = $personalGitEmail
  name = $personalGitName
  signingKey = $personalSigningKey
EOF
fi
