# TDD: OpenCode Curl-to-Bash Installer Generator

## Objective & Scope
- **What:** Create a script generator that produces a curl-to-bash installer for distributing OpenCode configuration files
- **Why:** Enable easy distribution and installation of OpenCode configs via `curl ... | bash` pattern, with flexible folder selection and environment-based overrides
- **File Target:** specs/tdd-opencode-installer.md

## Proposed Technical Strategy

### Logic Flow
1. **Configuration Phase:**
   - Create `installer.config` file listing default folders to include
   - Config is stored in the repository and fetched at install time

2. **Generator Script (`generate-installer.sh`):**
   - Reads local `installer.config` for reference
   - Generates a standalone bash installer script
   - The generated installer will:
     - Check for `PASTAS` environment variable (Option C override)
     - If not set, fetch `installer.config` from GitHub raw (Option B)
     - Download each folder from GitHub raw as tarball/zip or individual files
     - Create `.opencode/` directory in current working directory
     - Extract/copy all files maintaining structure

3. **Installer Behavior:**
   - Downloads from: `https://raw.githubusercontent.com/<user>/<repo>/<branch>/`
   - Creates `.opencode/` in the directory where the command is executed
   - Supports dry-run mode for testing
   - Shows progress and validates downloads

### Impacted Files
- `specs/tdd-opencode-installer.md` (this document)
- `installer.config` - Configuration file with default folders list
- `generate-installer.sh` - Script that generates the curl-to-bash installer
- `install-opencode.sh` (generated) - The actual installer distributed to users
- Optional: `tools/telegram-notify.ts` integration for notifications

### Language-Specific Guardrails
- **Bash/Shell:**
  - Use `set -euo pipefail` for strict error handling
  - Check all external dependencies (curl, tar, etc.) before execution
  - Validate directory creation and permissions
  - Use temporary files safely with `mktemp`
  - Clean up temp files on exit (trap)
  - Support both macOS and Linux (portable commands)

## Implementation Plan

### Phase 1: Configuration File
**File:** `installer.config`
```bash
# OpenCode Installer Configuration
# Edit this file to add/remove folders from installation

DEFAULT_FOLDERS="commands rules skills docs"
REPO_URL="https://raw.githubusercontent.com/<user>/<repo>/main"
```

### Phase 2: Generator Script
**File:** `generate-installer.sh`
```bash
#!/usr/bin/env bash
# Generates the curl-to-bash installer

set -euo pipefail

# Read local installer.config
# Generate install-opencode.sh with embedded logic:
#   - Check PASTAS env var
#   - If empty, fetch installer.config from GitHub raw
#   - Parse DEFAULT_FOLDERS
#   - Download each folder
#   - Create .opencode/ structure
#   - Handle errors and cleanup
```

### Phase 3: Generated Installer Features
**File:** `install-opencode.sh` (generated)
```bash
#!/usr/bin/env bash

# Features:
# 1. Environment variable override:
#    PASTAS="commands rules" curl ... | bash
#
# 2. GitHub raw download of config if no env var
# 3. Download folders via GitHub API or raw file fetching
# 4. Create .opencode/ in $PWD
# 5. Error handling and validation
# 6. Progress output
# 7. Cleanup on failure
```

### Phase 4: Advanced Features (Optional)
- Backup existing `.opencode/` before overwrite
- Uninstall functionality
- Version checking
- Telegram notification on completion

### Path Resolution
- Source files (for generation): Repository root
- Generated installer: Output to `dist/` or root
- Installation target: `$PWD/.opencode/` (user's current directory)

### Naming Standards
- Files: kebab-case (`generate-installer.sh`, `installer.config`)
- Variables: UPPER_SNAKE in scripts (`DEFAULT_FOLDERS`, `REPO_URL`)
- Functions: lowercase with underscores (`download_folder()`, `cleanup_temp()`)

## Workflow Summary

```mermaid
flowchart LR
    A[Developer edits installer.config] --> B[Run generate-installer.sh]
    B --> C[Generated install-opencode.sh]
    C --> D[User runs curl ... | bash]
    D --> E{PASTAS env var?}
    E -->|Yes| F[Use custom folders]
    E -->|No| G[Fetch installer.config]
    G --> H[Parse DEFAULT_FOLDERS]
    F --> I[Download from GitHub raw]
    H --> I
    I --> J[Create .opencode/ in $PWD]
```

## Distribution

User installs with:
```bash
# Default folders (from installer.config)
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install-opencode.sh | bash

# Custom folders (override)
PASTAS="commands docs" curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install-opencode.sh | bash
```
