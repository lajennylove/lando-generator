#!/bin/bash

# lando-generator-installer.sh
# Automated installation script for lando-generator
# This script will:
# 1. Detect the user's home directory
# 2. Find the lando-generator project location
# 3. Add the lando-create function to bashrc/zshrc
# 4. Copy SSH keys from ~/.ssh/ to setup/ directory

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_header() {
    echo -e "${BLUE}🚀 Lando Generator Installer${NC}"
    echo "=================================="
}

# Get the directory where this script is located
get_script_dir() {
    local script_path="${BASH_SOURCE[0]}"
    local script_dir="$(cd "$(dirname "$script_path")" && pwd)"
    echo "$script_dir"
}

# Detect user's shell
detect_shell() {
    local shell_name=$(basename "$SHELL")
    echo "$shell_name"
}

# Get the appropriate rc file path
get_rc_file() {
    local shell_name="$1"
    local home_dir="$HOME"
    
    case "$shell_name" in
        "bash")
            echo "$home_dir/.bashrc"
            ;;
        "zsh")
            echo "$home_dir/.zshrc"
            ;;
        *)
            echo "$home_dir/.bashrc"
            ;;
    esac
}

# Check if function already exists in rc file
function_exists() {
    local rc_file="$1"
    local function_name="lando-create"
    
    if [ -f "$rc_file" ]; then
        grep -q "^${function_name}()" "$rc_file" || grep -q "^# Lando Generator Function" "$rc_file"
    else
        return 1
    fi
}

# Add function to rc file
add_function_to_rc() {
    local rc_file="$1"
    local script_dir="$2"
    local shell_name="$3"
    
    print_info "Adding lando-create function to $rc_file"
    
    # Create backup
    if [ -f "$rc_file" ]; then
        cp "$rc_file" "${rc_file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_success "Created backup: ${rc_file}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Add function
    cat >> "$rc_file" << EOF

# Lando Generator Function
# Add this function to use lando-create from any directory
lando-create() {
    local script_path="$script_dir/lando-create.sh"
    
    if [ ! -f "\$script_path" ]; then
        echo "❌ Error: lando-create.sh not found at \$script_path"
        return 1
    fi
    
    # Call the script from the found location
    /bin/bash "\$script_path" "\$@"
}
EOF
    
    print_success "Added lando-create function to $rc_file"
}

# Copy SSH keys
copy_ssh_keys() {
    local script_dir="$1"
    local setup_dir="$script_dir/setup"
    
    print_info "Setting up SSH keys..."
    
    # Create setup directory if it doesn't exist
    if [ ! -d "$setup_dir" ]; then
        mkdir -p "$setup_dir"
        print_success "Created setup directory: $setup_dir"
    fi
    
    # Copy SSH keys if they exist
    local ssh_dir="$HOME/.ssh"
    local private_key="$ssh_dir/id_ed25519"
    local public_key="$ssh_dir/id_ed25519.pub"
    
    if [ -f "$private_key" ] && [ -f "$public_key" ]; then
        cp "$private_key" "$setup_dir/"
        cp "$public_key" "$setup_dir/"
        chmod 600 "$setup_dir/id_ed25519"
        chmod 644 "$setup_dir/id_ed25519.pub"
        print_success "Copied SSH keys to setup directory"
    else
        print_warning "SSH keys not found in $ssh_dir"
        print_info "You can manually copy your SSH keys later:"
        print_info "  cp ~/.ssh/id_ed25519* $setup_dir/"
    fi
}

# Test the installation
test_installation() {
    local script_dir="$1"
    local shell_name="$2"
    
    print_info "Testing installation..."
    
    # Test if script exists and is executable
    if [ -f "$script_dir/lando-create.sh" ]; then
        print_success "lando-create.sh script found"
    else
        print_error "lando-create.sh script not found"
        return 1
    fi
    
    # Test if function can be loaded
    print_info "To complete the installation, please run:"
    if [ "$shell_name" = "zsh" ]; then
        echo "  source ~/.zshrc"
    else
        echo "  source ~/.bashrc"
    fi
    echo ""
    print_info "Then test with: lando-create --help"
}

# Main installation function
main() {
    print_header
    
    # Get script directory
    local script_dir=$(get_script_dir)
    print_info "Lando Generator location: $script_dir"
    
    # Detect shell
    local shell_name=$(detect_shell)
    print_info "Detected shell: $shell_name"
    
    # Get rc file
    local rc_file=$(get_rc_file "$shell_name")
    print_info "RC file: $rc_file"
    
    # Check if function already exists
    if function_exists "$rc_file"; then
        print_warning "lando-create function already exists in $rc_file"
        read -p "Do you want to update it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    fi
    
    # Add function to rc file
    add_function_to_rc "$rc_file" "$script_dir" "$shell_name"
    
    # Copy SSH keys
    copy_ssh_keys "$script_dir"
    
    # Test installation
    test_installation "$script_dir" "$shell_name"
    
    print_success "Installation completed!"
    print_info "You can now use 'lando-create' from any directory"
    print_info "Example: lando-create my-project run-all"
}

# Run main function
main "$@"
