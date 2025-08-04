#!/bin/bash

# NixOS Configuration Sync Script
# Automates copying configuration files between repo and /etc/nixos/

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_DIR="$HOME/nixos-config"
SYSTEM_DIR="/etc/nixos"
CONFIG_FILES=("configuration.nix" "hardware-configuration.nix" "apps.nix")

# Helper functions
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

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "README.md" ]] || [[ ! -d ".git" ]]; then
        print_error "This script should be run from the nixos-config repository directory"
        print_error "Expected location: $REPO_DIR"
        exit 1
    fi
}

# Backup function
create_backup() {
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    for file in "${CONFIG_FILES[@]}"; do
        if [[ -f "$SYSTEM_DIR/$file" ]]; then
            sudo cp "$SYSTEM_DIR/$file" "$backup_dir/"
            print_status "Backed up $file to $backup_dir/"
        fi
    done
    
    # Fix ownership of backup
    sudo chown -R $USER:$USER backups/
}

# Pull: Copy FROM system TO repo
pull_configs() {
    print_status "Pulling configurations from $SYSTEM_DIR to repository..."
    
    # Create backup first (skip if no sudo)
    if command -v sudo >/dev/null && sudo -n true 2>/dev/null; then
        create_backup
    else
        print_warning "Skipping backup - sudo not available"
    fi
    
    for file in "${CONFIG_FILES[@]}"; do
        if [[ -f "$SYSTEM_DIR/$file" ]]; then
            if cp "$SYSTEM_DIR/$file" . 2>/dev/null; then
                print_success "Copied $file from system"
            elif command -v sudo >/dev/null && sudo cp "$SYSTEM_DIR/$file" . 2>/dev/null; then
                sudo chown $USER:$USER "$file"
                print_success "Copied $file from system (with sudo)"
            else
                print_error "Failed to copy $file - permission denied"
            fi
        else
            print_warning "$file not found in $SYSTEM_DIR"
        fi
    done
    
    print_success "Pull completed!"
    print_status "Don't forget to commit changes: git add . && git commit -m 'Update from system'"
}

# Push: Copy FROM repo TO system
push_configs() {
    print_status "Pushing configurations from repository to $SYSTEM_DIR..."
    
    for file in "${CONFIG_FILES[@]}"; do
        if [[ -f "$file" ]]; then
            print_status "Copying $file to system..."
            sudo cp "$file" "$SYSTEM_DIR/"
            print_success "Copied $file to system"
        else
            print_error "$file not found in repository"
            exit 1
        fi
    done
    
    print_success "Push completed!"
    print_status "Ready to rebuild system with: sudo nixos-rebuild switch"
}

# Rebuild system
rebuild_system() {
    print_status "Rebuilding NixOS system..."
    
    if sudo nixos-rebuild switch; then
        print_success "System rebuild completed successfully!"
    else
        print_error "System rebuild failed!"
        print_warning "You may need to fix configuration errors"
        print_warning "Use 'sudo nixos-rebuild switch --rollback' if needed"
        exit 1
    fi
}

# Test configuration
test_config() {
    print_status "Testing NixOS configuration..."
    
    if sudo nixos-rebuild test; then
        print_success "Configuration test passed!"
    else
        print_error "Configuration test failed!"
        print_warning "Please fix configuration errors before pushing"
        exit 1
    fi
}

# Dry build (syntax check)
dry_build() {
    print_status "Performing dry build (syntax check)..."
    
    if sudo nixos-rebuild dry-build; then
        print_success "Syntax check passed!"
    else
        print_error "Syntax check failed!"
        exit 1
    fi
}

# Show usage
show_usage() {
    echo "NixOS Configuration Sync Script"
    echo ""
    echo "Usage: $0 [COMMAND]"
    echo ""
    echo "Commands:"
    echo "  pull      Copy configurations FROM system TO repository"
    echo "  push      Copy configurations FROM repository TO system"
    echo "  rebuild   Rebuild NixOS system (after push)"
    echo "  test      Test configuration without switching"
    echo "  check     Perform syntax check (dry build)"
    echo "  backup    Create backup of current system config"
    echo "  help      Show this help message"
    echo ""
    echo "Workflow examples:"
    echo "  ./sync.sh pull           # Backup current system config"
    echo "  ./sync.sh push           # Apply repo config to system"
    echo "  ./sync.sh rebuild        # Rebuild system with new config"
    echo "  ./sync.sh test           # Test config before rebuilding"
    echo ""
}

# Main script logic
main() {
    check_directory
    
    case "${1:-help}" in
        "pull")
            pull_configs
            ;;
        "push")
            push_configs
            ;;
        "rebuild")
            rebuild_system
            ;;
        "test")
            test_config
            ;;
        "check")
            dry_build
            ;;
        "backup")
            create_backup
            ;;
        "help"|"--help"|"-h")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"