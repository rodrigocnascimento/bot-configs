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
#   Update mode (only updates if newer version available):
#   curl -fsSL ... | bash -s -- --update
#
#   Check mode (reports version status, no download):
#   curl -fsSL ... | bash -s -- --check
#
#   Force reinstall:
#   curl -fsSL ... | bash -s -- --force
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# Configuration
GITHUB_USER="rodrigocnascimento"
GITHUB_REPO="bot-configs"
GITHUB_BRANCH="main"
RAW_URL="https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}"
API_URL="https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/contents"
CONFIG_URL="${RAW_URL}/installer.config"
RELEASES_API_URL="https://api.github.com/repos/${GITHUB_USER}/${GITHUB_REPO}/releases"
VERSION_FILE="opencode.version"
BACKUP_DIR_NAME=".opencode.bak"

# Embedded version (updated at generation time)
EMBEDDED_VERSION="1.4.0"

# Target directory base
TARGET_BASE="${PWD:-.}" || true
: "${TARGET_BASE:=.}" || true
TEMP_DIR=""

# Resolve HOME if not set
HOME_DIR="${HOME:-}" || true

# Determine install directory based on runtime context (global vs local)
# If executing from ~/.config → global → use "opencode" (no dot)
# Otherwise → local → use ".opencode" (with dot)
if [[ -n "$HOME_DIR" && ("$TARGET_BASE" == "$HOME_DIR/.config" || "$TARGET_BASE" == "${HOME_DIR}/.config") ]]; then
    INSTALL_DIR="${TARGET_BASE}/opencode"
else
    INSTALL_DIR="${TARGET_BASE}/.opencode"
fi

# Legacy variable (kept for backward compatibility)
TARGET_DIR="${INSTALL_DIR}"
TARGET_DIR="${INSTALL_DIR}"

# Mode flags
MODE_INSTALL=true
MODE_UPDATE=false
MODE_CHECK=false
MODE_FORCE=false

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

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --update|-u)
                MODE_INSTALL=false
                MODE_UPDATE=true
                shift
                ;;
            --check|-c)
                MODE_INSTALL=false
                MODE_CHECK=true
                shift
                ;;
            --force|-f)
                MODE_FORCE=true
                shift
                ;;
            --help|-h)
                echo -e "${BOLD}OpenCode Config Installer${NC}"
                echo ""
                echo "Usage: curl -fsSL <url> | bash [-s -- <options>]"
                echo ""
                echo "Options:"
                echo "  --update, -u    Update only if newer version available"
                echo "  --check, -c     Check version status without downloading"
                echo "  --force, -f     Force reinstall/overwrite without prompting"
                echo "  --help, -h      Show this help message"
                echo ""
                echo "Environment variables:"
                echo "  PASTAS          Custom folders to install (space-separated)"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                error "Use --help for usage information"
                exit 1
                ;;
        esac
    done
}

# Check dependencies
check_deps() {
    local deps=("curl" "jq")
    for dep in ""; do
        if ! command -v "$dep" &> /dev/null; then
            error "$dep is required but not installed"
            exit 1
        fi
    done
}

# Compare two semver versions
# Outputs: "<" if v1 < v2, ">" if v1 > v2, "=" if equal
semver_compare() {
    local v1="$1" v2="$2"
    local IFS='.'
    # shellcheck disable=SC2207
    local a=(); read -ra a <<< "$v1"
    # shellcheck disable=SC2207
    local b=(); read -ra b <<< "$v2"

    for i in 0 1 2; do
        local ai=$(( 10#${a[i]:-0} ))
        local bi=$(( 10#${b[i]:-0} ))
        if (( ai < bi )); then echo "<"; return; fi
        if (( ai > bi )); then echo ">"; return; fi
    done

    echo "="
}

# Get local installed version
get_local_version() {
    if [[ -f "${TARGET_DIR}/${VERSION_FILE}" ]]; then
        cat "${TARGET_DIR}/${VERSION_FILE}" | tr -d '[:space:]'
    else
        echo "0.0.0"
    fi
}

# Get latest version from GitHub
get_latest_version() {
    local latest_version=""

    # Try GitHub releases API first
    latest_version=$(curl -sf "${RELEASES_API_URL}/latest" 2>/dev/null | grep '"tag_name"' | head -1 | cut -d'"' -f4 | sed 's/^v//') || true

    # Fallback: read package.json version from GitHub Raw
    if [[ -z "$latest_version" ]]; then
        latest_version=$(curl -sf "${RAW_URL}/package.json" 2>/dev/null | grep '"version"' | head -1 | cut -d'"' -f4) || true
    fi

    # Fallback: read opencode.version from GitHub Raw
    if [[ -z "$latest_version" ]]; then
        latest_version=$(curl -sf "${RAW_URL}/${VERSION_FILE}" 2>/dev/null | tr -d '[:space:]') || true
    fi

    echo "${latest_version:-0.0.0}"
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
    
    # Parse JSON and download recursively using jq
    local success_count=0
    local fail_count=0
    
    # Use jq to iterate through items and differentiate files from directories
    while IFS=$'\t' read -r type path; do
        [[ -z "$path" ]] && continue
        [[ "$path" == "$folder" ]] && continue
        
        local dest_path="${TARGET_DIR}/${path}"
        
        if [[ "$type" == "dir" ]]; then
            # Recursively download subdirectory
            if download_folder "$path"; then
                ((success_count++))
            else
                ((fail_count++))
            fi
        else
            # Download file
            if download_file "$path" "$dest_path"; then
                ((success_count++))
            else
                ((fail_count++))
                warning "Failed to download: ${path}"
            fi
        fi
    done <<< "$(echo "$contents" | jq -r '.[] | "\(.type)\t\(.path)"')"
    
    if [[ $fail_count -eq 0 ]]; then
        success "Downloaded ${success_count} items from ${folder}"
    else
        warning "Downloaded ${success_count} items, ${fail_count} failed from ${folder}"
    fi
    
    return $fail_count
}
    
    # Parse JSON and download files
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

# Alternative: Download using git archive
download_folder_git() {
    local folder="$1"
    local temp_zip
    temp_zip="${TEMP_DIR}/${folder}.zip"
    
    info "Downloading ${folder} via GitHub archive..."
    
    local archive_url="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/archive/${GITHUB_BRANCH}.zip"
    
    if curl -fsSL "$archive_url" -o "$temp_zip" 2>/dev/null; then
        if command -v unzip &> /dev/null; then
            unzip -q "$temp_zip" "${GITHUB_REPO}-${GITHUB_BRANCH}/${folder}/*" -d "$TEMP_DIR"
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

# Download version file
download_version_file() {
    local dest_path="/opencode.version"
    info "Downloading version file..."
    if download_file "opencode.version" ""; then
        # Ensure the embedded version is written
        echo "" > ""
        success "Version file written: "
        return 0
    else
        # Write embedded version as fallback
        echo "" > ""
        success "Version file written (embedded): "
        return 0
    fi
}

# Create opencode.json (required for all installations)
create_opencode_json() {
    local config_path="${INSTALL_DIR}/opencode.json"
    info "Creating opencode.json..."
    
    mkdir -p "." || true
    
    cat > "" <<'OPENCODE_JSON'
{
  "": "https://opencode.ai/config.json",
  "version": "1.0"
}
OPENCODE_JSON
    
    success "opencode.json created"
}

# Backup existing .opencode directory
backup_existing() {
    local backup_dir="${PWD}/${BACKUP_DIR_NAME}"
    
    if [[ ! -d "$TARGET_DIR" ]]; then
        return 0
    fi
    
    # Remove old backup if exists
    if [[ -d "$backup_dir" ]]; then
        rm -rf "$backup_dir"
    fi
    
    info "Backing up existing .opencode/ to ${BACKUP_DIR_NAME}/..."
    cp -r "$TARGET_DIR" "$backup_dir"
    success "Backup created: ${BACKUP_DIR_NAME}/"
}

# Check mode — only compare versions
do_check() {
    echo -e "${BOLD}OpenCode Version Check${NC}"
    echo "========================="
    echo ""
    
    check_deps
    
    local local_version
    local_version=$(get_local_version)
    
    local latest_version
    latest_version=$(get_latest_version)
    
    echo -e "Installed version: ${GREEN}${local_version}${NC}"
    echo -e "Latest version:    ${GREEN}${latest_version}${NC}"
    echo ""
    
    local comparison
    comparison=$(semver_compare "${local_version}" "${latest_version}")
    
    case "$comparison" in
        "<")
            echo -e "${YELLOW}⚠ Update available: ${local_version} → ${latest_version}${NC}"
            echo ""
            echo "To update, run:"
            echo "  curl -fsSL https://raw.githubusercontent.com/${GITHUB_USER}/${GITHUB_REPO}/${GITHUB_BRANCH}/dist/install-opencode.sh | bash -s -- --update"
            ;;
        "=")
            echo -e "${GREEN}✓ Already up to date (${local_version})${NC}"
            ;;
        ">")
            echo -e "${BLUE}ℹ Installed version (${local_version}) is newer than latest release (${latest_version})${NC}"
            ;;
        *)
            echo -e "${YELLOW}⚠ Could not determine version relationship${NC}"
            ;;
    esac
}

# Update mode — only update if newer version available
do_update() {
    echo -e "${BOLD}OpenCode Config Updater${NC}"
    echo "========================="
    echo ""
    
    check_deps
    TEMP_DIR=$(mktemp -d)
    
    local local_version
    local_version=$(get_local_version)
    
    local latest_version
    latest_version=$(get_latest_version)
    
    echo -e "Installed version: ${GREEN}${local_version}${NC}"
    echo -e "Latest version:    ${GREEN}${latest_version}${NC}"
    echo ""
    
    if [[ "${local_version}" == "0.0.0" ]]; then
        info "No existing installation found. Performing fresh install..."
        do_install
        return
    fi
    
    local comparison
    comparison=$(semver_compare "${local_version}" "${latest_version}")
    
    case "$comparison" in
        "=")
            success "Already up to date (${local_version}). No update needed."
            exit 0
            ;;
        ">")
            info "Installed version (${local_version}) is newer than latest release (${latest_version})."
            info "Skipping update."
            exit 0
            ;;
        "<")
            echo -e "${YELLOW}Update available: ${local_version} → ${latest_version}${NC}"
            echo ""
            
            # Backup before update
            backup_existing
            
            if [[ "${MODE_FORCE}" != true ]]; then
                read -p "Proceed with update? (Y/n): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Nn]$ ]]; then
                    info "Update cancelled"
                    exit 0
                fi
            fi
            
            # Proceed with installation (overwrite existing)
            info "Updating..."
            rm -rf "$TARGET_DIR"
            do_install
            ;;
        *)
            error "Could not determine version relationship"
            exit 1
            ;;
    esac
}

# Install mode — fresh or forced install
do_install() {
    echo -e "${GREEN}OpenCode Config Installer${NC}"
    echo "========================="
    echo ""
    
    # Check dependencies
    check_deps
    
    # Create temp directory
    if [[ -z "${TEMP_DIR:-}" ]]; then
        TEMP_DIR=$(mktemp -d)
    fi
    
    # Determine folders to install
    local folders_to_install
    
    if [[ -n "${PASTAS:-}" ]]; then
        info "Using custom folders from PASTAS environment variable"
        folders_to_install="$PASTAS"
    else
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
        if [[ "${MODE_FORCE}" == true ]]; then
            warning "Force mode: overwriting existing .opencode/"
            rm -rf "$TARGET_DIR"
        else
            warning ".opencode/ already exists in current directory"
            read -p "Overwrite? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                info "Installation cancelled"
                exit 0
            fi
            rm -rf "$TARGET_DIR"
        fi
    fi
    
# Create install directory
    mkdir -p ""
    success "Created "
    echo ""
    
    # Download each folder
    local total_folders=0
    local success_folders=0
    
    for folder in $folders_to_install; do
        ((total_folders++))
        if download_folder "$folder"; then
            ((success_folders++))
        else
            if download_folder_git "$folder"; then
                ((success_folders++))
            fi
        fi
    done
    
    # Download version file
    download_version_file
    
    # Create opencode.json (required)
    create_opencode_json
    
    echo ""
    echo "========================="
    if [[ $success_folders -eq $total_folders ]]; then
        success "Installation complete! (${success_folders}/${total_folders} folders)"
        echo ""
        info "Installed to: ${TARGET_DIR}"
        info "Version: ${EMBEDDED_VERSION}"
        success "OpenCode is ready to use!"
    else
        warning "Installation completed with issues (${success_folders}/${total_folders} folders)"
        warning "Some files may be missing. Check errors above."
    fi
}

# Main entry point
main() {
    parse_args "$@"
    
    if [[ "$MODE_CHECK" == true ]]; then
        do_check
    elif [[ "$MODE_UPDATE" == true ]]; then
        do_update
    else
        do_install
    fi
}

main "$@"
