echo "Installing homebrew ..."

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

install_bob_nvim() {
    print_status "Installing bob.nvim..."
    cargo install bob-nvim
    print_success "bob.nvim installed successfully"
}

install_cargo_update() {
    print_status "Installing cargo-update..."
    cargo install cargo-update
    print_success "cargo-update installed successfully"
}

main() {
    install_bob_nvim
    install_cargo_update
}

main
