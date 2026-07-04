#!/usr/bin/env bash
# gitconfig.sh
#
# Cross-platform git config setup for macOS and Linux (including NixOS).
# Creates a single ~/.gitconfig plus optional ~/.gitconfig.personal and
# ~/.gitconfig.work profile files.

set -euo pipefail

TARGET="$HOME/.gitconfig"

# --- OS detection ---
detect_os() {
  local uname
  uname=$(uname -s)
  if [[ "$uname" == "Darwin" ]]; then
    echo "macos"
  elif [[ -f /etc/NIXOS ]] || [[ -d /run/current-system/sw/bin ]]; then
    echo "nixos"
  elif [[ "$uname" == "Linux" ]]; then
    echo "linux"
  else
    echo "unknown"
  fi
}

OS=$(detect_os)
echo "Detected OS: $OS"
echo ""

# --- Helper path resolution ---
find_helper() {
  local name="$1"
  local mac_path="$2"
  local nixos_path="$3"

  if command -v "$name" >/dev/null 2>&1; then
    command -v "$name"
    return 0
  fi

  if [[ "$OS" == "macos" && -x "$mac_path" ]]; then
    echo "$mac_path"
    return 0
  fi

  if [[ "$OS" == "nixos" && -x "$nixos_path" ]]; then
    echo "$nixos_path"
    return 0
  fi

  return 1
}

GH_PATH=$(find_helper gh "/opt/homebrew/bin/gh" "/run/current-system/sw/bin/gh" || true)
SIGNER_PATH=$(find_helper op-ssh-sign "/Applications/1Password.app/Contents/MacOS/op-ssh-sign" "/run/current-system/sw/bin/op-ssh-sign" || true)

if [[ -z "$SIGNER_PATH" ]]; then
  echo "Warning: op-ssh-sign not found. Git commit signing will be disabled."
  echo "Install 1Password CLI or set the signer manually after running this script."
  echo ""
fi

# --- Existing file check ---
if [[ -f "$TARGET" ]]; then
  read -p "$TARGET already exists. Overwrite? (y/N): " confirm
  confirm=$(echo "$confirm" | tr '[:lower:]' '[:upper:]')
  if [[ "$confirm" != "Y" ]]; then
    echo "Aborted."
    exit 0
  fi
  echo ""
fi

# --- Profile setup ---
echo "=== Git profile setup ==="
echo ""

read -p "Add Personal profile? (Y/N): " addPersonal
addPersonal=$(echo "$addPersonal" | tr '[:lower:]' '[:upper:]')

read -p "Add Work profile? (Y/N): " addWork
addWork=$(echo "$addWork" | tr '[:lower:]' '[:upper:]')

default_profile=""
if [[ "$addPersonal" == "Y" && "$addWork" == "Y" ]]; then
  read -p "Which profile should be the default? [P]ersonal / [W]ork: " default_choice
  default_choice=$(echo "$default_choice" | tr '[:lower:]' '[:upper:]')
  if [[ "$default_choice" == "W" ]]; then
    default_profile="work"
  else
    default_profile="personal"
  fi
elif [[ "$addPersonal" == "Y" ]]; then
  default_profile="personal"
elif [[ "$addWork" == "Y" ]]; then
  default_profile="work"
fi

# --- Collect profile details ---
if [[ "$addPersonal" == "Y" ]]; then
  echo ""
  echo "=== Personal profile ==="
  read -p "Personal git name: " personalGitName
  read -p "Personal git email: " personalGitEmail
  read -p "Personal signing key: " personalSigningKey
  read -p "Personal code root directory (e.g. ~/personal, optional): " personalCodeLocation
fi

if [[ "$addWork" == "Y" ]]; then
  echo ""
  echo "=== Work profile ==="
  read -p "Work git name: " workGitName
  read -p "Work git email: " workGitEmail
  read -p "Work signing key: " workSigningKey
  read -p "Work code root directory (e.g. ~/work, optional): " workCodeLocation
fi

# --- Default identity ---
gitName=""
gitEmail=""
signingKey=""

if [[ -z "$default_profile" ]]; then
  echo ""
  echo "=== Default git identity ==="
  read -p "Git name: " gitName
  read -p "Git email: " gitEmail
  read -p "Signing key: " signingKey
else
  case "$default_profile" in
    personal)
      gitName="$personalGitName"
      gitEmail="$personalGitEmail"
      signingKey="$personalSigningKey"
      ;;
    work)
      gitName="$workGitName"
      gitEmail="$workGitEmail"
      signingKey="$workSigningKey"
      ;;
  esac
fi

# --- Private modules ---
echo ""
read -p "Enable private GitHub modules via token URL rewrite? (Y/N): " usePrivateModules
usePrivateModules=$(echo "$usePrivateModules" | tr '[:lower:]' '[:upper:]')

ghToken=""
ghOrg=""
if [[ "$usePrivateModules" == "Y" ]]; then
  read -p "GitHub access token: " ghToken
  read -p "GitHub organization root name: " ghOrg
fi

# --- Write main ~/.gitconfig ---
cat <<EOF > "$TARGET"
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
  navigate = true
  side-by-side = true
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
EOF

if [[ -n "$SIGNER_PATH" ]]; then
  cat <<EOF >> "$TARGET"
[gpg "ssh"]
  program = $SIGNER_PATH
[commit]
  gpgsign = true
EOF
else
  cat <<EOF >> "$TARGET"
[commit]
  gpgsign = false
EOF
fi

cat <<EOF >> "$TARGET"
[alias]
  leaderboard = shortlog --summary --numbered --all --no-merges
  sbr = "!rm \${GIT_PREFIX}\$1 && git checkout -- \${GIT_PREFIX}\$1 #"
[filter "strongbox"]
  clean = strongbox -clean %f
  smudge = strongbox -smudge %f
  required = true
[diff "strongbox"]
  textconv = strongbox -diff
EOF

if [[ -n "$GH_PATH" ]]; then
  cat <<EOF >> "$TARGET"
[credential "https://github.com"]
  helper = 
  helper = !$GH_PATH auth git-credential
[credential "https://gist.github.com"]
  helper = 
  helper = !$GH_PATH auth git-credential
EOF
fi

if [[ "$usePrivateModules" == "Y" ]]; then
  cat <<EOF >> "$TARGET"
[url "https://$ghToken:@github.com/$ghOrg"]
  insteadOf = https://github.com/$ghOrg
EOF
fi

# --- Write profile includes and files ---
expand_tilde() {
  local path="$1"
  if [[ "$path" == \~/* ]]; then
    path="${HOME}/${path#\~/}"
  elif [[ "$path" == \~ ]]; then
    path="$HOME"
  fi
  echo "$path"
}

write_profile_include() {
  local location="$1"
  local file="$2"
  location="${location%/}/"
  cat <<EOF >> "$TARGET"
[includeIf "gitdir:$location"]
  path = $file
EOF
}

if [[ "$addPersonal" == "Y" ]]; then
  # Always include the personal profile for the dotfiles repo location.
  cat <<EOF >> "$TARGET"
[includeIf "gitdir:~/configfiles/"]
  path = ~/.gitconfig.personal
EOF

  if [[ -n "$personalCodeLocation" ]]; then
    personalCodeLocationExpanded=$(expand_tilde "$personalCodeLocation")
    write_profile_include "$personalCodeLocation" "~/.gitconfig.personal"
    mkdir -p "$personalCodeLocationExpanded"
  fi

  cat <<EOF > "$HOME/.gitconfig.personal"
[user]
  email = $personalGitEmail
  name = $personalGitName
  signingKey = $personalSigningKey
EOF
fi

if [[ "$addWork" == "Y" ]]; then
  if [[ -n "$workCodeLocation" ]]; then
    workCodeLocationExpanded=$(expand_tilde "$workCodeLocation")
    write_profile_include "$workCodeLocation" "~/.gitconfig.work"
    mkdir -p "$workCodeLocationExpanded"
  fi

  cat <<EOF > "$HOME/.gitconfig.work"
[user]
  email = $workGitEmail
  name = $workGitName
  signingKey = $workSigningKey
EOF
fi

echo ""
echo "Git config written to $TARGET"
if [[ "$addPersonal" == "Y" ]]; then
  echo "Personal profile written to $HOME/.gitconfig.personal"
fi
if [[ "$addWork" == "Y" ]]; then
  echo "Work profile written to $HOME/.gitconfig.work"
fi

if [[ -n "$GH_PATH" ]]; then
  echo "GitHub credential helper: $GH_PATH"
fi
if [[ -n "$SIGNER_PATH" ]]; then
  echo "SSH signer: $SIGNER_PATH"
fi

echo ""
echo "Verify with: git config --list | grep -E 'user|signing|includeIf'"
