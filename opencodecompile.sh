#!/usr/bin/env bash

# opencode-compile - Compile commands, rules, skills into AGENTS.md

set -euo pipefail

ROOT=$(pwd)
AGENTS_MD="$ROOT/AGENTS.md"

BEGIN="<!-- BEGIN OPENCODE AUTO -->"
END_MARKER="<!-- END OPENCODE AUTO -->"

COMPILE_DIRS="commands rules skills"
EXCLUDED_DIRS="plans|node_modules"

collect_md_files() {
    local files=""
    for dir in $COMPILE_DIRS; do
        if [[ -d "$ROOT/$dir" ]]; then
            files+=$(find "$ROOT/$dir" -type f -name "*.md" 2>/dev/null | grep -vE "/($EXCLUDED_DIRS)/" || true)
            files+=$'\n'
        fi
    done
    echo "$files" | grep -v '^$' | sort
}

compile_section() {
    local output=""
    while IFS= read -r file_path; do
        local relative_path
        relative_path=$(realpath --relative-to="$ROOT" "$file_path")
        local content
        content=$(<"$file_path")
        content=$(echo "$content" | sed -e '/./,$!d' -e :a -e '/^\n*$/{$d;N;ba' -e '}')
        output+=$'\n\n'"## ${relative_path}"$'\n\n'"${content}"
    done
    echo "$output"
}

upsert() {
    local original="$1"
    local replacement="$2"
    local block="${BEGIN}"$'\n'"${replacement}"$'\n'"${END_MARKER}"
    if [[ "$original" == *"$BEGIN"* && "$original" == *"$END_MARKER"* ]]; then
        echo "$original" | awk -v begin="$BEGIN" -v end="$END_MARKER" -v block="$block" '
            $0 == begin { print block; skip=1; next }
            $0 == end { skip=0; next }
            !skip { print }
        '
    else
        printf '%s\n\n%s\n' "$original" "$block"
    fi
}

files=$(collect_md_files)
file_count=$(echo "$files" | wc -l)

if [[ -z "$files" ]]; then
    echo "No .md files found in commands/, rules/, skills/" >&2
    exit 1
fi

compiled=$(echo "$files" | compile_section)

compiled_block="# 🔒 Compiled OpenCode Configuration

> Auto-generated. Do not edit manually.
${compiled}"

if [[ -f "$AGENTS_MD" ]]; then
    existing=$(<"$AGENTS_MD")
else
    existing="# AGENTS.md"
fi

updated=$(upsert "$existing" "$compiled_block")
echo "$updated" > "$AGENTS_MD"

echo "✅ AGENTS.md compiled successfully."
echo "Included files: ${file_count}"
