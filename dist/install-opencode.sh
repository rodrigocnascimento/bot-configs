#!/usr/bin/env bash
#
# install-opencode.sh
# Installer for OpenCode configuration files
# Generated automatically - do not edit manually
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/rodrigocnascimento/bot-configs/main/dist/install-opencode.sh | bash
#
#   Or with custom folders:
#   PASTAS="commands docs" curl -fsSL ... | bash
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
GITHUB_USER="rodrigocnascimento"
GITHUB_REPO="bot-configs"
GITHUB_BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"
API_URL="https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/contents"
CONFIG_URL="${RAW_URL}/installer.config"

# Target directory
TARGET_DIR="${PWD}/.opencode"
TEMP_DIR=""

# Cleanup function
cleanup() {
    if [[ -n "${TEMP_DIR:-}" && -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

trap cleanup EXIT

# Print functions
info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warning() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1" >&2; }

# Check dependencies
check_deps() {
    local deps=("curl")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error "$dep is required but not installed"
            exit 1
        fi
    done
}

# Fetch and parse installer.config from GitHub
fetch_config() {
    local config_content
    config_content=$(curl -fsSL "$CONFIG_URL" 2>/dev/null) || {
        error "Failed to fetch installer.config from GitHub"
        return 1
    }
    
    # Extract DEFAULT_FOLDERS from config
    local folders
    folders=$(echo "$config_content" | grep "^DEFAULT_FOLDERS=" | cut -d'"' -f2)
    
    if [[ -z "$folders" ]]; then
        error "Could not parse DEFAULT_FOLDERS from config"
        return 1
    fi
    
    echo "$folders"
}

# Download a single file from GitHub raw
download_file() {
    local file_path="$1"
    local dest_path="$2"
    local url="${RAW_URL}/${file_path}"
    
    # Create directory if needed
    local dir
    dir=$(dirname "$dest_path")
    mkdir -p "$dir"
    
    if curl -fsSL "$url" -o "$dest_path" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Recursively download folder contents from GitHub API
download_folder() {
    local folder="$1"
    local api_url="${API_URL}/${folder}?ref=${GITHUB_BRANCH}"
    
    info "Downloading folder: ${folder}"
    
    # Fetch directory listing from GitHub API
    local contents
    contents=$(curl -fsSL "$api_url" 2>/dev/null) || {
        error "Failed to fetch directory listing for ${folder}"
        return 1
    }
    
    # Parse JSON and download files (using basic grep/sed for portability)
    # This extracts "path" values from the JSON array
    local files
    files=$(echo "$contents" | grep '"path"' | cut -d'"' -f4)
    
    local success_count=0
    local fail_count=0
    
    while IFS= read -r file_path; do
        [[ -z "$file_path" ]] && continue
        
        # Skip if it's the folder itself
        [[ "$file_path" == "$folder" ]] && continue
        
        local dest_path="${TARGET_DIR}/${file_path}"
        
        if download_file "$file_path" "$dest_path"; then
            ((success_count++))
        else
            ((fail_count++))
            warning "Failed to download: ${file_path}"
        fi
    done <<< "$files"
    
    if [[ $fail_count -eq 0 ]]; then
        success "Downloaded ${success_count} files from ${folder}"
    else
        warning "Downloaded ${success_count} files, ${fail_count} failed from ${folder}"
    fi
    
    return $fail_count
}

# Alternative: Download using git archive (if available)
download_folder_git() {
    local folder="$1"
    local temp_zip
    temp_zip="${TEMP_DIR}/${folder}.zip"
    
    info "Downloading ${folder} via GitHub archive..."
    
    local archive_url="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/${GITHUB_BRANCH}.zip"
    
    if curl -fsSL "$archive_url" -o "$temp_zip" 2>/dev/null; then
        # Extract specific folder
        if command -v unzip &> /dev/null; then
            unzip -q "$temp_zip" "${GITHUB_REPO}-${GITHUB_BRANCH}/${folder}/*" -d "$TEMP_DIR"
            # Move to target
            if [[ -d "${TEMP_DIR}/${GITHUB_REPO}-${GITHUB_BRANCH}/${folder}" ]]; then
                mkdir -p "${TARGET_DIR}/${folder}"
                cp -r "${TEMP_DIR}/${GITHUB_REPO}-${GITHUB_BRANCH}/${folder}"/* "${TARGET_DIR}/${folder}/"
                success "Downloaded ${folder}"
                return 0
            fi
        fi
    fi
    
    return 1
}

# Main installation function
install_opencode() {
    echo -e "${GREEN}OpenCode Config Installer${NC}"
    echo "========================="
    echo ""
    
    # Check dependencies
    check_deps
    
    # Create temp directory
    TEMP_DIR=$(mktemp -d)
    
    # Determine folders to install
    local folders_to_install
    
    if [[ -n "${PASTAS:-}" ]]; then
        # Use environment variable override (Option C)
        info "Using custom folders from PASTAS environment variable"
        folders_to_install="$PASTAS"
    else
        # Fetch from config (Option B)
        info "Fetching default configuration from GitHub..."
        folders_to_install=$(fetch_config) || {
            error "Could not fetch configuration"
            info "You can specify folders manually: PASTAS='commands rules' curl ... | bash"
            exit 1
        }
    fi
    
    echo -e "Folders to install: ${YELLOW}${folders_to_install}${NC}"
    echo ""
    
    # Check if target directory exists
    if [[ -d "$TARGET_DIR" ]]; then
        warning ".opencode/ already exists in current directory"
        read -p "Overwrite? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            info "Installation cancelled"
            exit 0
        fi
        rm -rf "$TARGET_DIR"
    fi
    
    # Create target directory
    mkdir -p "$TARGET_DIR"
    success "Created ${TARGET_DIR}"
    echo ""
    
    # Download each folder
    local total_folders=0
    local success_folders=0
    
    for folder in $folders_to_install; do
        ((total_folders++))
        if download_folder "$folder"; then
            ((success_folders++))
        else
            # Try alternative method
            if download_folder_git "$folder"; then
                ((success_folders++))
            fi
        fi
    done
    
    echo ""
    echo "========================="
    if [[ $success_folders -eq $total_folders ]]; then
        success "Installation complete! (${success_folders}/${total_folders} folders)"
        echo ""
        info "Installed to: ${TARGET_DIR}"
        success "OpenCode is ready to use!"
    else
        warning "Installation completed with issues (${success_folders}/${total_folders} folders)"
        warning "Some files may be missing. Check errors above."
    fi
}

# Run installation
install_opencode "$@"
