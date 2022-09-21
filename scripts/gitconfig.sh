// gpg --list-secret-keys --keyid-format=long

read -p "Please enter the git name to be used: " gitName
read -p "Please enter the git email to be used: " gitEmail
read -p "Which signing key do you want to use: " signingKey
read -p "Do you want to be able to download private modules (Y/N): " usePrivateModules
if [[ $usePrivateModules == "Y" ]]; then
  read -p "Please enter a GitHub access token to be used: " ghToken
  read -p "What is the github organisation root name: " ghOrg
fi


echo "The GitHub access token you enter was $ghToken"

cat <<EOF > $HOME/.gitconfig
[user]
  email = $gitEmail
  name = $gitName
  signingKey = $signingKey
[core]
  editor = nvim
  excludesFile = ~/.gitignore_global
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
EOF


if [[ $usePrivateModules == "Y" ]]; then
cat <<EOF >> $HOME/.gitconfigtest
[url "https://$ghToken:@github.com/$ghOrg"]
  insteadOf = https://github.com/$ghOrg
EOF
fi
