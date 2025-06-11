#!/bin/bash

# Kanata macOS Setup Script
# This script sets up kanata keyboard remapper as a macOS service using launchctl

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
KANATA_BINARY_PATH="/opt/homebrew/bin/kanata"  # Default Homebrew path
KANATA_CONFIG_PATH="$HOME/.config/kanata/kanata.kbd"
PLIST_FILE="com.example.kanata.plist"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_FILE"
SERVICE_NAME="com.example.kanata"

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

check_requirements() {
    print_status "Checking requirements..."
    
    # Check if kanata is installed
    if ! command -v kanata &> /dev/null; then
        print_error "kanata is not installed or not in PATH"
        print_status "Installing kanata via Homebrew..."
        if command -v brew &> /dev/null; then
            brew install kanata
        else
            print_error "Homebrew not found. Please install Homebrew first or install kanata manually"
            exit 1
        fi
    fi
    
    # Find kanata binary path
    KANATA_BINARY_PATH=$(which kanata)
    print_success "Found kanata at: $KANATA_BINARY_PATH"
}

create_plist() {
    print_status "Creating launchd plist file..."
    
    # Create LaunchAgents directory if it doesn't exist
    mkdir -p "$HOME/Library/LaunchAgents"
    
    cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$SERVICE_NAME</string>
    <key>ProgramArguments</key>
    <array>
        <string>sudo $KANATA_BINARY_PATH</string>
        <string>-d</string>
        <string>-c</string>
        <string>$KANATA_CONFIG_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/kanata.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/kanata.error.log</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin</string>
    </dict>
</dict>
</plist>
EOF
    
    print_success "Plist file created at: $PLIST_PATH"
}

setup_logging() {
    print_status "Setting up logging directory..."
    mkdir -p "$HOME/Library/Logs"
    touch "$HOME/Library/Logs/kanata.log"
    touch "$HOME/Library/Logs/kanata.error.log"
    print_success "Log files created"
}

check_permissions() {
    print_warning "IMPORTANT: Kanata requires accessibility permissions to work properly."
    print_status "Please follow these steps:"
    echo "1. Open System Preferences (or System Settings on newer macOS)"
    echo "2. Go to Security & Privacy > Privacy > Accessibility"
    echo "3. Add Terminal (or your terminal app) to the list"
    echo "4. If running as a service, you may also need to add kanata binary"
    echo ""
    print_status "You can also run the following command to open accessibility settings:"
    echo "open 'x-apple.systempreferences:com.apple.preferences.security?Privacy_Accessibility'"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --config-path PATH    Path to kanata configuration file (default: $KANATA_CONFIG_PATH)"
    echo "  --binary-path PATH    Path to kanata binary (default: auto-detect)"
    echo "  --uninstall          Uninstall the kanata service"
    echo "  --status             Show service status"
    echo "  --load               Load the service"
    echo "  --unload             Unload the service"
    echo "  --start              Start the service"
    echo "  --stop               Stop the service"
    echo "  --restart            Restart the service"
    echo "  --logs               Show recent logs"
    echo "  --help               Show this help message"
}

uninstall_service() {
    print_status "Uninstalling kanata service..."
    
    # Stop and unload the service
    launchctl stop "$SERVICE_NAME" 2>/dev/null || true
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    
    # Remove plist file
    if [ -f "$PLIST_PATH" ]; then
        rm "$PLIST_PATH"
        print_success "Plist file removed"
    fi
    
    print_success "Kanata service uninstalled"
}

show_status() {
    print_status "Checking kanata service status..."
    if launchctl list | grep -q "$SERVICE_NAME"; then
        print_success "Service is loaded"
        launchctl list "$SERVICE_NAME"
    else
        print_warning "Service is not loaded"
    fi
}

unload_service() {
    print_status "Unoading kanata service..."
    launchctl unload "$PLIST_PATH" 2>/dev/null || true
    print_success "Service unloaded successfully"
}

load_service() {
    print_status "Loading kanata service..."
    launchctl load "$PLIST_PATH"
    print_success "Service loaded successfully"
}

start_service() {
    print_status "Starting kanata service..."
    launchctl start "$SERVICE_NAME"
    print_success "Service started"
}

stop_service() {
    print_status "Stopping kanata service..."
    launchctl stop "$SERVICE_NAME"
    print_success "Service stopped"
}

restart_service() {
    print_status "Restarting kanata service..."
    launchctl stop "$SERVICE_NAME" 2>/dev/null || true
    sleep 1
    launchctl start "$SERVICE_NAME"
    print_success "Service restarted"
}

show_logs() {
    print_status "Recent kanata logs:"
    echo "=== Standard Output ==="
    tail -20 "$HOME/Library/Logs/kanata.log" 2>/dev/null || echo "No standard output logs found"
    echo ""
    echo "=== Error Output ==="
    tail -20 "$HOME/Library/Logs/kanata.error.log" 2>/dev/null || echo "No error logs found"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --config-path)
            KANATA_CONFIG_PATH="$2"
            shift 2
            ;;
        --binary-path)
            KANATA_BINARY_PATH="$2"
            shift 2
            ;;
        --uninstall)
            uninstall_service
            exit 0
            ;;
        --status)
            show_status
            exit 0
            ;;
        --load)
            load_service
            exit 0
            ;;
        --unload)
            unload_service
            exit 0
            ;;
        --start)
            start_service
            exit 0
            ;;
        --stop)
            stop_service
            exit 0
            ;;
        --restart)
            restart_service
            exit 0
            ;;
        --logs)
            show_logs
            exit 0
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Main installation process
main() {
    print_status "Starting kanata macOS setup..."
    
    check_requirements
    create_plist
    setup_logging
    unload_service
    load_service
    start_service
    
    print_success "Kanata setup completed successfully!"
    echo ""
    check_permissions
    echo ""
    print_status "Useful commands:"
    echo "  Check status: $0 --status"
    echo "  Load service: $0 --load"
    echo "  Unload service: $0 --unload"
    echo "  Start service: $0 --start"
    echo "  Stop service: $0 --stop"
    echo "  Restart service: $0 --restart"
    echo "  View logs: $0 --logs"
    echo "  Uninstall: $0 --uninstall"
    echo ""
    print_status "Configuration file location: $KANATA_CONFIG_PATH"
    print_status "Service logs: $HOME/Library/Logs/kanata.log"
}

# Run main function
main
