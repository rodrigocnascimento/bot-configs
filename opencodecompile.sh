#!/usr/bin/env bash

# opencode-compile - Compile all .opencode rules into AGENTS.md
# Bash port of the Node.js opencode-compile.mjs script

set -euo pipefail

ROOT=$(pwd)
OPENCODE_DIR="$ROOT/.opencode"
AGENTS_MD="$ROOT/AGENTS.md"

BEGIN="<!-- BEGIN OPENCODE AUTO -->"
END_MARKER="<!-- END OPENCODE AUTO -->"

# Directories that should NOT be compiled
EXCLUDED_DIRS="plans|node_modules"

# Collect only .md files, excluding unwanted directories
collect_md_files() {
    find "$OPENCODE_DIR" -type f -name "*.md" \
        | grep -vE "/($EXCLUDED_DIRS)/" \
        | sort
}

# Compile all .md files into a single block
compile_section() {
    local output=""

    while IFS= read -r file_path; do
        local relative_path
        relative_path=$(realpath --relative-to="$OPENCODE_DIR" "$file_path")

        local content
        content=$(<"$file_path")

        # Trim leading/trailing blank lines only (preserve internal formatting)
        content=$(echo "$content" | sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}')

        output+=$'\n\n'"## ${relative_path}"$'\n\n'"${content}"
    done

    echo "$output"
}

# Replace or append the compiled block into AGENTS.md
upsert() {
    local original="$1"
    local replacement="$2"
    local block="${BEGIN}"$'\n'"${replacement}"$'\n'"${END_MARKER}"

    if [[ "$original" == *"$BEGIN"* && "$original" == *"$END_MARKER"* ]]; then
        # Use awk to replace everything between BEGIN and END markers
        echo "$original" | awk -v begin="$BEGIN" -v end="$END_MARKER" -v block="$block" '
            $0 == begin { print block; skip=1; next }
            $0 == end { skip=0; next }
            !skip { print }
        '
    else
        printf '%s\n\n%s\n' "$original" "$block"
    fi
}

# Main execution
if [[ ! -d "$OPENCODE_DIR" ]]; then
    echo "Error: .opencode directory not found." >&2
    exit 1
fi

# Collect files
files=$(collect_md_files)
file_count=$(echo "$files" | wc -l)

if [[ -z "$files" ]]; then
    echo "No .md files found in .opencode/" >&2
    exit 1
fi

# Compile sections from collected files
compiled=$(echo "$files" | compile_section)

compiled_block="# 🔒 Compiled OpenCode Configuration

> Auto-generated. Do not edit manually.
${compiled}"

# Read existing AGENTS.md or create default
if [[ -f "$AGENTS_MD" ]]; then
    existing=$(<"$AGENTS_MD")
else
    existing="# AGENTS.md"
fi

# Upsert compiled block into AGENTS.md
updated=$(upsert "$existing" "$compiled_block")

# Write result
echo "$updated" > "$AGENTS_MD"

echo "✅ AGENTS.md compiled successfully."
echo "Included files: ${file_count}"
