gpg --list-secret-keys --keyid-format=long

read -p "Which signing key do you want to use: " signingKey

read -p "Please enter a GitHub access token to be used: " ghToken
read -p "Please enter the git email to be used: " gitEmail
read -p "Do you want to be able to download private modules (Y/N): " usePrivateModules
if [[ $usePrivateModules == "Y" ]]; then
  read -p "What is the github organisation root name: " ghOrg
fi


echo "The GitHub access token you enter was $ghToken"

cat <<EOF > $HOME/.gitconfigtest
[user]
  email = $gitEmail
  name = Vitor Faiante
  signingKey = $signingKey
[core]
  editor = nvim
  excludesFile = ~/.gitignore_global
[init]
  defaultBranch = master
[status]
  short = true
[commit]
  gpgsign = true
EOF


if [[ $usePrivateModules == "Y" ]]; then
cat <<EOF >> $HOME/.gitconfigtest
[url "https://$ghToken:@github.com/$ghOrg"]
  insteadOf = https://github.com/$ghOrg
EOF
fi
