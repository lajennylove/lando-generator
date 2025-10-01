#!/bin/bash

# lando-create.sh - Script to generate .lando.yml files from template
# Usage: ./lando-create.sh <project-name> [run-all]
# Can be run from any directory - will create .lando.yml in current directory

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if project name is provided
if [ $# -eq 0 ]; then
    print_error "Error: Project name is required"
    echo "Usage: $0 <project-name> [run-all]"
    echo "Example: $0 roa-project"
    echo "Example: $0 roa-project run-all"
    exit 1
fi

PROJECT_NAME="$1"
RUN_ALL="$2"
TEMPLATE_FILE="$SCRIPT_DIR/.lando.example.yml"
OUTPUT_FILE=".lando.yml"

# Validate project name (alphanumeric, hyphens, underscores only)
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    print_error "Error: Project name can only contain letters, numbers, hyphens, and underscores"
    exit 1
fi

# Check if template file exists
if [ ! -f "$TEMPLATE_FILE" ]; then
    print_error "Error: Template file '$TEMPLATE_FILE' not found"
    echo "Make sure you're running this script from the directory containing the template file"
    exit 1
fi

# Check if output file already exists
if [ -f "$OUTPUT_FILE" ]; then
    if [ "$RUN_ALL" = "run-all" ]; then
        print_warning "Warning: '$OUTPUT_FILE' already exists - overwriting for run-all mode"
    else
        print_warning "Warning: '$OUTPUT_FILE' already exists"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Operation cancelled"
            exit 1
        fi
    fi
fi

print_success "Creating .lando.yml for project: $PROJECT_NAME"

# Create the new .lando.yml file by replacing placeholders
sed -e "s/^name: .*/name: $PROJECT_NAME/" \
    -e "s|/app/web/wp-content/themes/pacific|/app/web/wp-content/themes/$PROJECT_NAME|g" \
    -e "s|PROJECT_NAME|$PROJECT_NAME|g" \
    "$TEMPLATE_FILE" > "$OUTPUT_FILE"

print_success "Successfully created $OUTPUT_FILE"
print_success "Project name '$PROJECT_NAME' has been applied to:"
echo "  - name: $PROJECT_NAME"
echo "  - theme path: /app/web/wp-content/themes/$PROJECT_NAME"

# Clean up any existing setup directory (from previous runs)
if [ -d "setup" ]; then
    print_info "Removing existing setup directory to avoid duplicates..."
    rm -rf setup
    print_success "Existing setup directory removed"
fi

# Verify SSH keys exist in central location
print_info "Verifying SSH keys in central location..."
if [ -f "$SCRIPT_DIR/setup/id_ed25519" ] && [ -f "$SCRIPT_DIR/setup/id_ed25519.pub" ]; then
    print_success "SSH keys found in central location - will be used directly"
else
    print_warning "SSH keys not found in central location: $SCRIPT_DIR/setup/"
    print_info "Make sure you have id_ed25519 and id_ed25519.pub in the setup directory"
fi

echo
print_success "You can now run 'lando start' to start your development environment"

# Function to run all setup steps
execute_run_all() {
    print_info "Starting automated setup for project: $PROJECT_NAME"
    echo
    
    # Step 2: Start Lando
    print_info "Step 2: Starting Lando environment..."
    if ! lando start; then
        print_error "Failed to start Lando environment"
        exit 1
    fi
    print_success "Lando environment started successfully"
    echo

    
    # Step 3: Install WordPress
    print_info "Step 3: Installing WordPress..."
    if ! lando wpinstall; then
        print_error "Failed to install WordPress"
        exit 1
    fi
    print_success "WordPress installed successfully"
    echo
    
    # Step 4: Install Sage theme
    print_info "Step 4: Installing Sage theme..."
    if ! lando sageinstall; then
        print_error "Failed to install Sage theme"
        exit 1
    fi
    print_success "Sage theme installed successfully"
    echo
    
    # Step 5: Install and configure Acorn
    print_info "Step 5: Installing and configuring Acorn..."
    if ! lando acorninstall; then
        print_error "Failed to install and configure Acorn"
        exit 1
    fi
    print_success "Acorn installed and configured successfully"
    echo
    
    # Step 6: Install PEST testing framework
    print_info "Step 6: Installing PEST testing framework..."
    if ! lando pestinstall; then
        print_error "Failed to install PEST testing framework"
        exit 1
    fi
    print_success "PEST testing framework installed successfully"
    echo
    
    # Step 7: Install and activate ACF Pro plugin
    print_info "Step 7: Installing and activating ACF Pro plugin..."
    if ! lando inst-acf; then
        print_error "Failed to install and activate ACF Pro plugin"
        exit 1
    fi
    print_success "ACF Pro plugin installed and activated successfully"
    echo

    # Step 8: Install ACF Composer
    print_info "Step 8: Installing ACF Composer..."
    if ! lando inst-acf-composer; then
        print_error "Failed to install ACF Composer"
        exit 1
    fi
    print_success "ACF Composer installed successfully"
    echo

    # Step 9: Install Poet
    print_info "Step 9: Installing Poet..."
    if ! lando inst-poet; then
        print_error "Failed to install Poet"
        exit 1
    fi
    print_success "Poet installed successfully"
    echo
    
    # Step 10: Install Node dependencies
    print_info "Step 10: Installing Node dependencies..."
    if ! lando inst; then
        print_error "Failed to install Node dependencies"
        exit 1
    fi
    print_success "Node dependencies installed successfully"
    echo
    
    # Step 11: Build assets
    print_info "Step 11: Building assets..."
    if ! lando build; then
        print_error "Failed to build assets"
        exit 1
    fi
    print_success "Assets built successfully"
    echo
    
    # Final cleanup - remove any setup directory that might have been created
    if [ -d "setup" ]; then
        print_info "Cleaning up temporary setup directory..."
        rm -rf setup
        print_success "Temporary setup directory removed"
    fi
    
    print_success "🎉 Complete setup finished for project: $PROJECT_NAME"
    print_info "Your WordPress site with Sage theme, Acorn, PEST testing, ACF Composer, and Poet is ready!"
    print_info "Visit: http://$PROJECT_NAME.lndo.site/"
}

# Execute run-all if requested
if [ "$RUN_ALL" = "run-all" ]; then
    execute_run_all
fi
